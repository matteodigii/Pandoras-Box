#pragma once

#include <JuceHeader.h>
#include "ParamIDs.h"
#include "DryWetMixer.h"

//==============================================================================
/**
    Distortion processor module with configurable drive level.
*/
class PandoraDistortion
{
public:
    PandoraDistortion();
    ~PandoraDistortion();

    void prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels);
    void processBlock(juce::AudioBuffer<float>& buffer);
    void updateParams(juce::AudioProcessorValueTreeState& apvts);

    void reset() noexcept;

private:
    float lastSampleRate{ 0 };
    int totalNumInputChannels{ 2 };

    enum
    {
        filterIndex,
        preGainIndex,
        waveshaperIndex,
        postGainIndex
    };

    using Filter = juce::dsp::IIR::Filter<float>;
    using FilterCoefs = juce::dsp::IIR::Coefficients<float>;

    juce::SmoothedValue<float, juce::ValueSmoothingTypes::Linear> distDrive;

    juce::dsp::ProcessorChain<
        juce::dsp::ProcessorDuplicator<Filter, FilterCoefs>,
        juce::dsp::Gain<float>,
        juce::dsp::WaveShaper<float>,
        juce::dsp::Gain<float>> processorChain;

    void initializeChain();

    DryWetMixer mixer;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(PandoraDistortion)
};