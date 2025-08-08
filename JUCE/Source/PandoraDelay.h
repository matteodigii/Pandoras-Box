#pragma once

#include <JuceHeader.h>
#include "DryWetMixer.h"

//==============================================================================
/*
*/
class PandoraDelay
{
public:
    PandoraDelay();
    ~PandoraDelay();
    void prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels);
    void processBlock(juce::AudioBuffer<float>& buffer);
    void updateParams(juce::AudioProcessorValueTreeState& apvts);

private:

    float lastSampleRate{ 0 };
    int totalNumInputChannels{ 2 };

    juce::AudioBuffer<float> delayBuffer;
    float oldSample[2] = { 0.0, 0.0 };

    int writePosition{ 0 };

    juce::SmoothedValue<float, juce::ValueSmoothingTypes::Linear> delayFeedback;
    juce::SmoothedValue<float, juce::ValueSmoothingTypes::Linear> delayTime;

    DryWetMixer mixer;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(PandoraDelay)
};