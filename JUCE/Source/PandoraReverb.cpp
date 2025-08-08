#pragma once
#include <JuceHeader.h>
#include "ParamIDs.h"
#include "PandoraReverb.h"

//==============================================================================
PandoraReverb::PandoraReverb()
{
    // In your constructor, you should add any child components, and
    // initialise any special settings that your component needs.
}

PandoraReverb::~PandoraReverb()
{
}



void PandoraReverb::prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels)
{
    lastSampleRate = sampleRate;
    juce::dsp::ProcessSpec spec;

    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = samplesPerBlock;
    spec.numChannels = numOutputChannels;

    reverb.prepare(spec);

    reverbParams.roomSize = Parameters::reverb::roomDefaultValue;
    reverbParams.damping = 0.5f;
    reverbParams.wetLevel = Parameters::reverb::mixDefaultValue;
    reverbParams.dryLevel = 1.0f - Parameters::reverb::roomDefaultValue;;
    reverbParams.width = Parameters::reverb::widthDefaultValue;
    reverbParams.freezeMode = 0.0f;
    reverb.setParameters(reverbParams);

    reverb.reset();
}

void PandoraReverb::processBlock(juce::AudioBuffer<float>& buffer)
{
    juce::dsp::AudioBlock<float> block(buffer);
    juce::dsp::ProcessContextReplacing ctx(block);
    reverb.process(ctx);
}

void PandoraReverb::updateParams(juce::AudioProcessorValueTreeState& apvts)
{
    reverbParams.wetLevel = *apvts.getRawParameterValue(Parameters::reverb::mixId);
    reverbParams.dryLevel = 1.0f - *apvts.getRawParameterValue(Parameters::reverb::mixId);
    reverbParams.width = *apvts.getRawParameterValue(Parameters::reverb::widthId);
    reverbParams.roomSize = *apvts.getRawParameterValue(Parameters::reverb::roomId);
    reverb.setParameters(reverbParams);
}
