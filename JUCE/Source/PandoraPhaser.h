#pragma once

#include <JuceHeader.h>

//==============================================================================
/*
*/
class PandoraPhaser
{
public:
    PandoraPhaser();
    ~PandoraPhaser();
    void prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels);
    void processBlock(juce::AudioBuffer<float>& buffer);
    void updateParams(juce::AudioProcessorValueTreeState& apvts);

private:

    juce::dsp::Phaser<float> phaser;

    float lastSampleRate;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(PandoraPhaser)

};