#pragma once

namespace Parameters
{
    struct ParameterInfo
    {
        const char* id;
        const char* label;
        float minValue;
        float maxValue;
        float defaultValue;
    };

    namespace distortion
    {
        inline constexpr ParameterInfo mixInfo{ "distortion_mix", "Distortion", 0.0f, 1.0f, 0.0f };
        inline constexpr ParameterInfo driveInfo{ "distortion_drive", "Drive", 0.0f, 1.0f, 1.0f };

        inline constexpr auto& mixLabel = mixInfo.label;
        inline constexpr auto& mixId = mixInfo.id;
        inline constexpr auto& mixMinValue = mixInfo.minValue;
        inline constexpr auto& mixMaxValue = mixInfo.maxValue;
        inline constexpr auto& mixDefaultValue = mixInfo.defaultValue;

        
        inline constexpr auto& driveLabel = driveInfo.label;
        inline constexpr auto& driveId = driveInfo.id;
        inline constexpr auto& driveMinValue = driveInfo.minValue;
        inline constexpr auto& driveMaxValue = driveInfo.maxValue;
        inline constexpr auto& driveDefaultValue = driveInfo.defaultValue;
        
    }

    namespace reverb
    {
        inline constexpr ParameterInfo mixInfo{ "reverb_level", "Reverb", 0.0f, 1.0f, 0.0f };
        inline constexpr ParameterInfo widthInfo{ "reverb_width", "Width", 0.0f, 1.0f, 0.5f };
        inline constexpr ParameterInfo roomInfo{ "reverb_room", "Room", 0.0f, 1.0f, 0.5f };

        inline constexpr auto& mixLabel = mixInfo.label;
        inline constexpr auto& mixId = mixInfo.id;
        inline constexpr auto& mixMinValue = mixInfo.minValue;
        inline constexpr auto& mixMaxValue = mixInfo.maxValue;
        inline constexpr auto& mixDefaultValue = mixInfo.defaultValue;

        inline constexpr auto& widthLabel = widthInfo.label;
        inline constexpr auto& widthId = widthInfo.id;
        inline constexpr auto& widthMinValue = widthInfo.minValue;
        inline constexpr auto& widthMaxValue = widthInfo.maxValue;
        inline constexpr auto& widthDefaultValue = widthInfo.defaultValue;

        inline constexpr auto& roomLabel = roomInfo.label;
        inline constexpr auto& roomId = roomInfo.id;
        inline constexpr auto& roomMinValue = roomInfo.minValue;
        inline constexpr auto& roomMaxValue = roomInfo.maxValue;
        inline constexpr auto& roomDefaultValue = roomInfo.defaultValue;
    }

    namespace phaser
    {
        inline constexpr ParameterInfo mixInfo{ "phaser_level", "Phaser", 0.0f, 1.0f, 0.0f };
        inline constexpr ParameterInfo depthInfo{ "phaser_depth", "Depth", 0.02f, 2.0f, 0.5f };

        inline constexpr auto& mixLabel = mixInfo.label;
        inline constexpr auto& mixId = mixInfo.id;
        inline constexpr auto& mixMinValue = mixInfo.minValue;
        inline constexpr auto& mixMaxValue = mixInfo.maxValue;
        inline constexpr auto& mixDefaultValue = mixInfo.defaultValue;

        inline constexpr auto& depthLabel = depthInfo.label;
        inline constexpr auto& depthId = depthInfo.id;
        inline constexpr auto& depthMinValue = depthInfo.minValue;
        inline constexpr auto& depthMaxValue = depthInfo.maxValue;
        inline constexpr auto& depthDefaultValue = depthInfo.defaultValue;
    }

    namespace chorus
    {
        inline constexpr ParameterInfo mixInfo{ "chorus_mix", "Chorus", 0.0f, 1.0f, 0.0f };
        inline constexpr ParameterInfo rateInfo{ "chorus_rate", "Rate", 0.05f, 10.0f, 0.25f };
        inline constexpr ParameterInfo depthInfo{ "chorus_depth", "Depth", 0.0f, 1.0f, 0.4f };

        inline constexpr auto& mixLabel = mixInfo.label;
        inline constexpr auto& mixId = mixInfo.id;
        inline constexpr auto& mixMinValue = mixInfo.minValue;
        inline constexpr auto& mixMaxValue = mixInfo.maxValue;
        inline constexpr auto& mixDefaultValue = mixInfo.defaultValue;

        inline constexpr auto& rateLabel = rateInfo.label;
        inline constexpr auto& rateId = rateInfo.id;
        inline constexpr auto& rateMinValue = rateInfo.minValue;
        inline constexpr auto& rateMaxValue = rateInfo.maxValue;
        inline constexpr auto& rateDefaultValue = rateInfo.defaultValue;

        inline constexpr auto& depthLabel = depthInfo.label;
        inline constexpr auto& depthId = depthInfo.id;
        inline constexpr auto& depthMinValue = depthInfo.minValue;
        inline constexpr auto& depthMaxValue = depthInfo.maxValue;
        inline constexpr auto& depthDefaultValue = depthInfo.defaultValue;
    }

    namespace delay
    {
        inline constexpr ParameterInfo mixInfo{ "delay_mix", "Delay", 0.0f, 1.0f, 0.0f };
        inline constexpr ParameterInfo fbInfo{ "delay_fb", "Feedback", 0.0f, 1.0f, 0.2f };
        inline constexpr ParameterInfo timeInfo{ "delay_time", "Time", 0.02f, 2.0f, 0.5f };

        inline constexpr auto& mixLabel = mixInfo.label;
        inline constexpr auto& mixId = mixInfo.id;
        inline constexpr auto& mixMinValue = mixInfo.minValue;
        inline constexpr auto& mixMaxValue = mixInfo.maxValue;
        inline constexpr auto& mixDefaultValue = mixInfo.defaultValue;

        inline constexpr auto& fbLabel = fbInfo.label;
        inline constexpr auto& fbId = fbInfo.id;
        inline constexpr auto& fbMinValue = fbInfo.minValue;
        inline constexpr auto& fbMaxValue = fbInfo.maxValue;
        inline constexpr auto& fbDefaultValue = fbInfo.defaultValue;

        inline constexpr auto& timeLabel = timeInfo.label;
        inline constexpr auto& timeId = timeInfo.id;
        inline constexpr auto& timeMinValue = timeInfo.minValue;
        inline constexpr auto& timeMaxValue = timeInfo.maxValue;
        inline constexpr auto& timeDefaultValue = timeInfo.defaultValue;
    }

    namespace gain
    {
        inline constexpr ParameterInfo info{ "gain_level", "Gain", 0.0f, 2.0f, 1.0f };

        inline constexpr auto& label = info.label;
        inline constexpr auto& id = info.id;
        inline constexpr auto& minValue = info.minValue;
        inline constexpr auto& maxValue = info.maxValue;
        inline constexpr auto& defaultValue = info.defaultValue;
    }
}
