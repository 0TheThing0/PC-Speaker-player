WAVFileData db 44 dup ?
EnableSound db 0

Value dw 0
Mid dd 32769
MainCoeff dd ?

SamplingSize dd BASE_SAMPLE_SIZE
SampleValue dd BASE_SAMPLE_VALUE
SoundCoeff dd BASE_HEAR_SOUND

TimeInSeconds dd 0
FullTime dd 0

TrackHours db 0
TrackMinutes db 0
TrackSeconds db 0

DrawPos dw 0

ACoeff dd 0.3
NACoeff dd 0.7
TimeCoeff dd 0.0322580645
SamplingRate dw ?
EndSound db 0
StopSound db 0

RandomState db 0
