/*
  ==============================================================================

	This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"
#include "ParamIDs.h"

//==============================================================================
PandoraFxAudioProcessor::PandoraFxAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
	: AudioProcessor(BusesProperties()
#if ! JucePlugin_IsMidiEffect
#if ! JucePlugin_IsSynth
		.withInput("Input", juce::AudioChannelSet::stereo(), true)
#endif
		.withOutput("Output", juce::AudioChannelSet::stereo(), true)
#endif
	),
	apvts(*this, nullptr, "Parameters", createParameters())
#endif
{
}

PandoraFxAudioProcessor::~PandoraFxAudioProcessor()
{
}

//==============================================================================
const juce::String PandoraFxAudioProcessor::getName() const
{
	return JucePlugin_Name;
}

bool PandoraFxAudioProcessor::acceptsMidi() const
{
#if JucePlugin_WantsMidiInput
	return true;
#else
	return false;
#endif
}

bool PandoraFxAudioProcessor::producesMidi() const
{
#if JucePlugin_ProducesMidiOutput
	return true;
#else
	return false;
#endif
}

bool PandoraFxAudioProcessor::isMidiEffect() const
{
#if JucePlugin_IsMidiEffect
	return true;
#else
	return false;
#endif
}

double PandoraFxAudioProcessor::getTailLengthSeconds() const
{
	return 0.0;
}

int PandoraFxAudioProcessor::getNumPrograms()
{
	return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
	// so this should be at least 1, even if you're not really implementing programs.
}

int PandoraFxAudioProcessor::getCurrentProgram()
{
	return 0;
}

void PandoraFxAudioProcessor::setCurrentProgram(int index)
{
}

const juce::String PandoraFxAudioProcessor::getProgramName(int index)
{
	return {};
}

void PandoraFxAudioProcessor::changeProgramName(int index, const juce::String& newName)
{
}

//==============================================================================
void PandoraFxAudioProcessor::prepareToPlay(double sampleRate, int samplesPerBlock)
{
	int totalNumOutputChannels = getTotalNumOutputChannels();
	lastSampleRate = sampleRate;

	pDistortion.prepareToPlay(sampleRate, samplesPerBlock, totalNumOutputChannels);
	pReverb.prepareToPlay(sampleRate, samplesPerBlock, totalNumOutputChannels);
	pDelay.prepareToPlay(sampleRate, samplesPerBlock, totalNumOutputChannels);
	pChorus.prepareToPlay(sampleRate, samplesPerBlock, totalNumOutputChannels);
	pPhaser.prepareToPlay(sampleRate, samplesPerBlock, totalNumOutputChannels);

	prepareGain(sampleRate, samplesPerBlock, totalNumOutputChannels);

}

void PandoraFxAudioProcessor::prepareGain(double sampleRate, int samplesPerBlock, int numOutputChannels) {
	juce::dsp::ProcessSpec spec;

	spec.sampleRate = sampleRate;
	spec.maximumBlockSize = samplesPerBlock;
	spec.numChannels = numOutputChannels;
	gain.prepare(spec);
	gain.reset();
	gain.setRampDurationSeconds(0.05);
	gain.setGainLinear(1.0f);
}

void PandoraFxAudioProcessor::releaseResources()
{
	// When playback stops, you can use this as an opportunity to free up any
	// spare memory, etc.

}

#ifndef JucePlugin_PreferredChannelConfigurations
bool PandoraFxAudioProcessor::isBusesLayoutSupported(const BusesLayout& layouts) const
{
#if JucePlugin_IsMidiEffect
	juce::ignoreUnused(layouts);
	return true;
#else
	// This is the place where you check if the layout is supported.
	// In this template code we only support mono or stereo.
	// Some plugin hosts, such as certain GarageBand versions, will only
	// load plugins that support stereo bus layouts.
	if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
		&& layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
		return false;

	// This checks if the input layout matches the output layout
#if ! JucePlugin_IsSynth
	if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
		return false;
#endif

	return true;
#endif
}
#endif

juce::AudioProcessorValueTreeState::ParameterLayout PandoraFxAudioProcessor::createParameters()
{
	std::vector<std::unique_ptr<juce::RangedAudioParameter>> parameters;

	// 1 - Distortion
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::distortion::mixId, Parameters::distortion::mixLabel, Parameters::distortion::mixMinValue, Parameters::distortion::mixMaxValue, Parameters::distortion::mixDefaultValue));
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::distortion::driveId, Parameters::distortion::driveLabel, Parameters::distortion::driveMinValue, Parameters::distortion::driveMaxValue, Parameters::distortion::driveDefaultValue));

	// 2 - Reverb
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::reverb::mixId, Parameters::reverb::mixLabel, Parameters::reverb::mixMinValue, Parameters::reverb::mixMaxValue, Parameters::reverb::mixDefaultValue));
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::reverb::roomId, Parameters::reverb::roomLabel, Parameters::reverb::roomMinValue, Parameters::reverb::roomMaxValue, Parameters::reverb::roomDefaultValue));
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::reverb::widthId, Parameters::reverb::widthLabel, Parameters::reverb::widthMinValue, Parameters::reverb::widthMaxValue, Parameters::reverb::widthDefaultValue));

	// 3 - Phaser
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::phaser::mixId, Parameters::phaser::mixLabel, Parameters::phaser::mixMinValue, Parameters::phaser::mixMaxValue, Parameters::phaser::mixDefaultValue));
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::phaser::depthId, Parameters::phaser::depthLabel, Parameters::phaser::depthMinValue, Parameters::phaser::depthMaxValue, Parameters::phaser::depthDefaultValue));

	// 4 - Chorus
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::chorus::mixId, Parameters::chorus::mixLabel, Parameters::chorus::mixMinValue, Parameters::chorus::mixMaxValue, Parameters::chorus::mixDefaultValue));
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::chorus::rateId, Parameters::chorus::rateLabel, Parameters::chorus::rateMinValue, Parameters::chorus::rateMaxValue, Parameters::chorus::rateDefaultValue));
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::chorus::depthId, Parameters::chorus::depthLabel, Parameters::chorus::depthMinValue, Parameters::chorus::depthMaxValue, Parameters::chorus::depthDefaultValue));
	
	// 5 - Delay
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::delay::mixId, Parameters::delay::mixLabel, Parameters::delay::mixMinValue, Parameters::delay::mixMaxValue, Parameters::delay::mixDefaultValue));
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::delay::fbId, Parameters::delay::fbLabel, Parameters::delay::fbMinValue, Parameters::delay::fbMaxValue, Parameters::delay::fbDefaultValue));
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::delay::timeId, Parameters::delay::timeLabel, Parameters::delay::timeMinValue, Parameters::delay::timeMaxValue, Parameters::delay::timeDefaultValue));
	
	// 6 - Post Gain
	parameters.push_back(std::make_unique<juce::AudioParameterFloat>(Parameters::gain::id, Parameters::gain::label, Parameters::gain::minValue, Parameters::gain::maxValue, Parameters::gain::defaultValue));

	return { parameters.begin(), parameters.end() };
}

void PandoraFxAudioProcessor::updateParams()
{
	pDistortion.updateParams(apvts);
	pReverb.updateParams(apvts);
	pDelay.updateParams(apvts);
	pChorus.updateParams(apvts);
	pPhaser.updateParams(apvts);

	gain.setGainLinear(*apvts.getRawParameterValue(Parameters::gain::id));
}

void PandoraFxAudioProcessor::processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
	juce::ScopedNoDenormals noDenormals;
	auto totalNumInputChannels = getTotalNumInputChannels();
	auto totalNumOutputChannels = getTotalNumOutputChannels();

	for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i)
		buffer.clear(i, 0, buffer.getNumSamples());

	// Update parameters from UI
	updateParams();

	// Process chain
	pDistortion.processBlock(buffer);
	pReverb.processBlock(buffer);
	pDelay.processBlock(buffer);
	pChorus.processBlock(buffer);
	pPhaser.processBlock(buffer);

	// Gain
	applyGain(buffer);
}

void PandoraFxAudioProcessor::applyGain(juce::AudioBuffer<float>& buffer) {
	juce::dsp::AudioBlock<float> block(buffer);
	juce::dsp::ProcessContextReplacing ctx(block);
	gain.process(ctx);
}

//==============================================================================
bool PandoraFxAudioProcessor::hasEditor() const
{
	return true; // (change this to false if you choose to not supply an editor)
}

juce::AudioProcessorEditor* PandoraFxAudioProcessor::createEditor()
{
	return new PandoraFxAudioProcessorEditor(*this);
}

//==============================================================================
void PandoraFxAudioProcessor::getStateInformation(juce::MemoryBlock& destData)
{
	// You should use this method to store your parameters in the memory block.
	// You could do that either as raw data, or use the XML or ValueTree classes
	// as intermediaries to make it easy to save and load complex data.
}

void PandoraFxAudioProcessor::setStateInformation(const void* data, int sizeInBytes)
{
	// You should use this method to restore your parameters from this memory block,
	// whose contents will have been created by the getStateInformation() call.
}

//==============================================================================
// This creates new instances of the plugin..
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
	return new PandoraFxAudioProcessor();
}
