WAVFileData db 44 dup ?
EnableSound db 0

Value dw 0
Mid dd 32769
MainCoeff dd ?

SamplingSize dd BASE_SAMPLE_SIZE
SampleValue dd BASE_SAMPLE_VALUE
SoundCoeff dd BASE_HEAR_SOUND
ACoeff dd 0.3
NACoeff dd 0.7
SamplingRate dw ?
EndSound db 0
StopSound db 0