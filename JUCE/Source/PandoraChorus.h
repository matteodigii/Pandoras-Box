#pragma once

#include <JuceHeader.h>
#include "DryWetMixer.h"

//==============================================================================
/*
*/
class PandoraChorus
{
public:
    PandoraChorus();
    ~PandoraChorus();
    void prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels);
    void processBlock(juce::AudioBuffer<float>& buffer);
    void updateParams(juce::AudioProcessorValueTreeState& apvts);

private:

    juce::dsp::Chorus<float> chorusLeft;
    juce::dsp::Chorus<float> chorusRight;

    DryWetMixer mixer;

    float lastSampleRate;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(PandoraChorus)

};