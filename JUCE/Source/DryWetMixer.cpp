#pragma once
#include <JuceHeader.h>
#include "ParamIDs.h"
#include "DryWetMixer.h"

//==============================================================================
DryWetMixer::DryWetMixer()
{
    // In your constructor, you should add any child components, and
    // initialise any special settings that your component needs.
}

DryWetMixer::~DryWetMixer()
{
}



void DryWetMixer::prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels)
{
    lastSampleRate = sampleRate;

    drySignal.setSize(numOutputChannels, samplesPerBlock);
    drySignal.clear();

    dryLevel.reset(sampleRate, 0.1);
    wetLevel.reset(sampleRate, 0.1);

    updateInternalState();
}

void DryWetMixer::copyDrySignal(juce::AudioBuffer<float>& buffer)
{
    const auto numSamples = buffer.getNumSamples();

    for (int ch = 0; ch < buffer.getNumChannels(); ++ch)
        drySignal.copyFrom(ch, 0, buffer, ch, 0, numSamples);
}

void DryWetMixer::merge(juce::AudioBuffer<float>& buffer)
{
    const auto numSamples = buffer.getNumSamples();

    wetLevel.applyGain(buffer, numSamples);
    dryLevel.applyGain(drySignal, numSamples);

    for (int ch = 0; ch < buffer.getNumChannels(); ++ch)
        buffer.addFrom(ch, 0, drySignal, ch, 0, numSamples);
}

void DryWetMixer::setDryWetRatio(const float newValue)
{
    dryWetRatio = newValue;
    updateInternalState();
}

void DryWetMixer::setActive(bool newValue)
{
    active = newValue;
    updateInternalState();
}

void DryWetMixer::updateInternalState()
{
    if (active)
    {
        dryLevel.setTargetValue(sqrt(1 - dryWetRatio));
        wetLevel.setTargetValue(sqrt(dryWetRatio));
    }
    else
    {
        dryLevel.setTargetValue(1.0f);
        wetLevel.setTargetValue(0.0f);
    }
}