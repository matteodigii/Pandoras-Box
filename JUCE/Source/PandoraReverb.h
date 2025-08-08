#pragma once

#include <JuceHeader.h>

//==============================================================================
/*
*/
class PandoraReverb
{
public:
    PandoraReverb();
    ~PandoraReverb();
    void prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels);
    void processBlock(juce::AudioBuffer<float>& buffer);
    void updateParams(juce::AudioProcessorValueTreeState& apvts);

private:

    juce::dsp::Reverb::Parameters reverbParams;
    juce::dsp::Reverb reverb;

    float lastSampleRate;


    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(PandoraReverb)

};