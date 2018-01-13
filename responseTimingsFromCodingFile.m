function [latency, duration] = responseTimingsFromCodingFile(trials)

latency = trials.SpOnset - trials.BaseBack;
duration = trials.SpEnd - trials.SpOnset;