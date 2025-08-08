#pragma once
#include <JuceHeader.h>
#include "ParamIDs.h"
#include "PandoraChorus.h"

//==============================================================================
PandoraChorus::PandoraChorus()
{
    // In your constructor, you should add any child components, and
    // initialise any special settings that your component needs.
}

PandoraChorus::~PandoraChorus()
{
}



void PandoraChorus::prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels)
{
    // Mixer 
    mixer.prepareToPlay(sampleRate, samplesPerBlock, numOutputChannels);
    mixer.setDryWetRatio(Parameters::delay::mixDefaultValue);

    // Chorus
    lastSampleRate = sampleRate;
    juce::dsp::ProcessSpec spec;

    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = samplesPerBlock;
    spec.numChannels = numOutputChannels;

    chorusLeft.prepare(spec);
    chorusRight.prepare(spec);

    chorusLeft.setCentreDelay(10.0f);
    chorusRight.setCentreDelay(11.0f);

    chorusLeft.setFeedback(0.0f);
    chorusRight.setFeedback(0.0f);

    chorusLeft.setRate(Parameters::chorus::rateDefaultValue);
    chorusLeft.setDepth(Parameters::chorus::depthDefaultValue);
    chorusLeft.setMix(1.0f);

    chorusRight.setRate(Parameters::chorus::rateDefaultValue);
    chorusRight.setDepth(Parameters::chorus::depthDefaultValue);
    chorusRight.setMix(1.0f);

    chorusLeft.reset();
    chorusRight.reset();
}

void PandoraChorus::processBlock(juce::AudioBuffer<float>& buffer)
{
    mixer.copyDrySignal(buffer);

    juce::dsp::AudioBlock<float> block(buffer);

    auto leftBlock = block.getSingleChannelBlock(0);
    auto rightBlock = block.getSingleChannelBlock(1);

    juce::dsp::ProcessContextReplacing<float> leftContext(leftBlock);
    juce::dsp::ProcessContextReplacing<float> rightContext(rightBlock);

    chorusLeft.process(leftContext);
    chorusRight.process(rightContext);

    mixer.merge(buffer);
}

void PandoraChorus::updateParams(juce::AudioProcessorValueTreeState& apvts)
{
    mixer.setDryWetRatio(*apvts.getRawParameterValue(Parameters::chorus::mixId) * 0.5f);

    chorusLeft.setRate(*apvts.getRawParameterValue(Parameters::chorus::rateId));
    chorusRight.setRate(*apvts.getRawParameterValue(Parameters::chorus::rateId));

    chorusLeft.setDepth(*apvts.getRawParameterValue(Parameters::chorus::depthId));
    chorusRight.setDepth(*apvts.getRawParameterValue(Parameters::chorus::depthId));
}
