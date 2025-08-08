/*
  ==============================================================================

	This file contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>
#include "PandoraDistortion.h"
#include "PandoraReverb.h"
#include "PandoraDelay.h"
#include "PandoraChorus.h"
#include "PandoraPhaser.h"
#include "ParamIDs.h"

//==============================================================================
/**
*/
class PandoraFxAudioProcessor : public juce::AudioProcessor
{
public:
	//==============================================================================
	PandoraFxAudioProcessor();
	~PandoraFxAudioProcessor() override;

	//==============================================================================
	void prepareToPlay(double sampleRate, int samplesPerBlock) override;
	void releaseResources() override;

#ifndef JucePlugin_PreferredChannelConfigurations
	bool isBusesLayoutSupported(const BusesLayout& layouts) const override;
#endif

	void processBlock(juce::AudioBuffer<float>&, juce::MidiBuffer&) override;

	//==============================================================================
	juce::AudioProcessorEditor* createEditor() override;
	bool hasEditor() const override;

	//==============================================================================
	const juce::String getName() const override;

	bool acceptsMidi() const override;
	bool producesMidi() const override;
	bool isMidiEffect() const override;
	double getTailLengthSeconds() const override;

	//==============================================================================
	int getNumPrograms() override;
	int getCurrentProgram() override;
	void setCurrentProgram(int index) override;
	const juce::String getProgramName(int index) override;
	void changeProgramName(int index, const juce::String& newName) override;

	//==============================================================================
	void getStateInformation(juce::MemoryBlock& destData) override;
	void setStateInformation(const void* data, int sizeInBytes) override;

	juce::AudioProcessorValueTreeState apvts;
	juce::AudioProcessorValueTreeState::ParameterLayout createParameters();

private:
	PandoraDistortion pDistortion;
	PandoraReverb pReverb;
	PandoraDelay pDelay;
	PandoraChorus pChorus;
	PandoraPhaser pPhaser;

	juce::dsp::Gain<float> gain;
	void prepareGain(double sampleRate, int samplesPerBlock, int numOutputChannels);
	void applyGain(juce::AudioBuffer<float>& buffer);
	void updateParams();
	float lastSampleRate;

	JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(PandoraFxAudioProcessor)
};