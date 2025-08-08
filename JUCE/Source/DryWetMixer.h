#pragma once

#include <JuceHeader.h>

//==============================================================================
/*
*/
class DryWetMixer
{
public:
    DryWetMixer();
    ~DryWetMixer();
    void prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels);
    void copyDrySignal(juce::AudioBuffer<float>& buffer);
    void merge(juce::AudioBuffer<float>& buffer);
    void setDryWetRatio(const float newValue);
    void setActive(bool newValue);
private:
    void updateInternalState();
    
    juce::AudioBuffer<float> drySignal;
    
    bool active{ true };

    float dryWetRatio{1.0f};


    juce::SmoothedValue<float, juce::ValueSmoothingTypes::Linear> dryLevel;

    juce::SmoothedValue<float, juce::ValueSmoothingTypes::Linear> wetLevel;


    float lastSampleRate;


    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(DryWetMixer)

};