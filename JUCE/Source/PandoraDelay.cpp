#pragma once
#include <JuceHeader.h>
#include "ParamIDs.h"
#include "PandoraDelay.h"

//==============================================================================
PandoraDelay::PandoraDelay()
{
    delayFeedback.setCurrentAndTargetValue(Parameters::delay::fbDefaultValue);
    delayFeedback.setCurrentAndTargetValue(Parameters::delay::timeDefaultValue);
}

PandoraDelay::~PandoraDelay()
{
}



void PandoraDelay::prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels)
{
    // Mixer 
    mixer.prepareToPlay(sampleRate, samplesPerBlock, numOutputChannels);
    mixer.setDryWetRatio(Parameters::delay::mixDefaultValue);

    // Delay
    lastSampleRate = sampleRate;
    totalNumInputChannels = numOutputChannels;
    auto delayBufferSize = sampleRate * 2.0; // 2 seconds in samples
    delayBuffer.setSize(numOutputChannels, static_cast<int>(delayBufferSize));
    delayBuffer.clear();

    delayTime.reset(sampleRate, 0.2);
    delayFeedback.reset(sampleRate, 0.02);
}

void PandoraDelay::processBlock(juce::AudioBuffer<float>& buffer)
{
    mixer.copyDrySignal(buffer);

    const auto numCh = buffer.getNumChannels();
    const auto numInputSamples = buffer.getNumSamples();

    auto bufferData = buffer.getArrayOfWritePointers();
    auto delayData = delayBuffer.getArrayOfWritePointers();

    auto delayBufferSize = delayBuffer.getNumSamples();

    for (int smp = 0; smp < numInputSamples; ++smp)
    {
        auto time = delayTime.getNextValue();
        auto feedback = delayFeedback.getNextValue();

        auto readPosition = writePosition - (time * lastSampleRate); // it can be a fractional value
        if (readPosition < 0)
            readPosition += delayBufferSize;

        auto integerPart = static_cast<int>(readPosition);
        auto fractionalPart = readPosition - integerPart;
        auto alpha = fractionalPart / (2.0 - fractionalPart); // interpolation factor

        auto delayBufferSize = delayBuffer.getNumSamples();

        auto A = (integerPart + delayBufferSize) % delayBufferSize;
        auto B = (A + 1) % delayBufferSize;

        for (int ch = 0; ch < numCh; ++ch)
        {
            // Input -> delay memory
            delayData[ch][writePosition] = bufferData[ch][smp];

            // FRACTIONAL DELAY :: Interpolazione Allpass
            auto sampleValue = alpha * (delayData[ch][B] - oldSample[ch]) + delayData[ch][A];
            oldSample[ch] = sampleValue;

            // Delay memory -> buffer
            bufferData[ch][smp] += sampleValue;

            // Feedback
            delayData[ch][writePosition] += sampleValue * feedback;

        }
        writePosition++;
        writePosition %= delayBufferSize;
    }

    mixer.merge(buffer);
}

void PandoraDelay::updateParams(juce::AudioProcessorValueTreeState& apvts)
{
    mixer.setDryWetRatio(*apvts.getRawParameterValue(Parameters::delay::mixId));

    delayFeedback.setTargetValue(*apvts.getRawParameterValue(Parameters::delay::fbId));
    delayTime.setTargetValue(*apvts.getRawParameterValue(Parameters::delay::timeId));
  }