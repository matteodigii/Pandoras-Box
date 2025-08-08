#pragma once
#include <JuceHeader.h>
#include "ParamIDs.h"
#include "PandoraPhaser.h"

//==============================================================================
PandoraPhaser::PandoraPhaser()
{
    // In your constructor, you should add any child components, and
    // initialise any special settings that your component needs.
}

PandoraPhaser::~PandoraPhaser()
{
}



void PandoraPhaser::prepareToPlay(double sampleRate, int samplesPerBlock, int numOutputChannels)
{
    lastSampleRate = sampleRate;
    juce::dsp::ProcessSpec spec;

    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = samplesPerBlock;
    spec.numChannels = numOutputChannels;

    phaser.prepare(spec);

    phaser.setRate(1.0f);
    phaser.setDepth(0.0f);
    phaser.setCentreFrequency(1500.0f);
    phaser.setFeedback(0.0f);
    phaser.setMix(0.0f);

    phaser.reset();
}

void PandoraPhaser::processBlock(juce::AudioBuffer<float>& buffer)
{
    juce::dsp::AudioBlock<float> block(buffer);
    juce::dsp::ProcessContextReplacing ctx(block);
    phaser.process(ctx);
}

void PandoraPhaser::updateParams(juce::AudioProcessorValueTreeState& apvts)
{
    phaser.setMix(*apvts.getRawParameterValue(Parameters::phaser::mixId));
    phaser.setDepth(*apvts.getRawParameterValue(Parameters::phaser::depthId));
    //phaser.setFeedback(*apvts.getRawParameterValue(Parameters::phaser::fbId) * 0.5f);
}