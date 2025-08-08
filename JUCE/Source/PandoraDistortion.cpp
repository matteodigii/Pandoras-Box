#include <JuceHeader.h>
#include "PandoraDistortion.h"
#include "ParamIDs.h"

//==============================================================================
PandoraDistortion::PandoraDistortion()
{
    initializeChain();
    distDrive.setCurrentAndTargetValue(0.0f);
}

PandoraDistortion::~PandoraDistortion()
{
}

void PandoraDistortion::initializeChain()
{
    // Delay
    // Setup waveshaper to use tanh for distortion
    auto& waveshaper = processorChain.get<waveshaperIndex>();
    waveshaper.functionToUse = [](float x) { return std::tanh(x); };

    // Default pre- and post-gain
    processorChain.get<preGainIndex>().setGainDecibels(0.0f);
    processorChain.get<postGainIndex>().setGainDecibels(-20.0f);
}

void PandoraDistortion::prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels)
{
    // Mixer 
    mixer.prepareToPlay(sampleRate, samplesPerBlock, numOutputChannels);
    mixer.setDryWetRatio(0.0f);

    // Distortion
    lastSampleRate = sampleRate;
    totalNumInputChannels = numOutputChannels;

    juce::dsp::ProcessSpec spec;
    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = samplesPerBlock;
    spec.numChannels = static_cast<juce::uint32>(numOutputChannels);

    // High-pass filter at 1 kHz
    auto& filter = processorChain.get<filterIndex>();
    filter.state = FilterCoefs::makeFirstOrderHighPass(sampleRate, 1000.0f);

    // Prepare DSP chain and reset state
    processorChain.prepare(spec);
    processorChain.reset();

    distDrive.reset(sampleRate, 0.02);
}

void PandoraDistortion::processBlock(juce::AudioBuffer<float>& buffer)
{
    mixer.copyDrySignal(buffer);

    const int numSamples = buffer.getNumSamples();
    const int numChannels = buffer.getNumChannels();

    // Create an AudioBlock for processing one sample at a time
    juce::dsp::AudioBlock<float> audioBlock(buffer);

    for (int sample = 0; sample < numSamples; ++sample)
    {
        // Get the next smoothed value
        float drive = distDrive.getNextValue();

        // Set pre-gain using the current drive value
        processorChain.get<preGainIndex>().setGainDecibels(drive * 30.0f);

        // Create a temporary buffer to hold one sample across all channels
        juce::AudioBuffer<float> tempBuffer(numChannels, 1);

        for (int ch = 0; ch < numChannels; ++ch)
        {
            tempBuffer.setSample(ch, 0, buffer.getSample(ch, sample));
        }

        // Create block and context for a single-sample processing
        juce::dsp::AudioBlock<float> tempBlock(tempBuffer);
        juce::dsp::ProcessContextReplacing<float> context(tempBlock);

        processorChain.process(context);

        // Copy processed sample back to original buffer
        for (int ch = 0; ch < numChannels; ++ch)
        {
            buffer.setSample(ch, sample, tempBuffer.getSample(ch, 0));
        }
    }

    mixer.merge(buffer);
}

void PandoraDistortion::updateParams(juce::AudioProcessorValueTreeState& apvts)
{
    // Drive parameter: maps 0..1 to 0..30 dB pre-gain
    distDrive.setTargetValue(*apvts.getRawParameterValue(Parameters::distortion::driveId));

    mixer.setDryWetRatio(*apvts.getRawParameterValue(Parameters::distortion::mixId));
}

void PandoraDistortion::reset() noexcept
{
    processorChain.reset();
}