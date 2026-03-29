# libavfilter CMakeLists.txt
# Generated from libavfilter/Makefile by tools/gen_avfilter_cmake.py
# All source files are listed explicitly (no file(GLOB) usage).

# ============================================================================
# Core sources (unconditional, from OBJS = in Makefile)
# ============================================================================
set(avfilter_sources
    # allfilters.c is replaced by generated allfilters.c (see below)
    audio.c
    avfilter.c
    avfiltergraph.c
    buffersink.c
    buffersrc.c
    colorspace.c
    ccfifo.c
    drawutils.c
    formats.c
    framepool.c
    framequeue.c
    graphdump.c
    graphparser.c
    version.c
    video.c
)

# ============================================================================
# Conditional sources based on CONFIG_* variables
# (from OBJS-$(CONFIG_*) in Makefile)
# ============================================================================

# --- Subsystems and helpers ---
if(CONFIG_QSVVPP)
    list(APPEND avfilter_sources qsvvpp.c)
endif()

if(CONFIG_SCENE_SAD)
    list(APPEND avfilter_sources scene_sad.c)
endif()

if(CONFIG_DNN)
    list(APPEND avfilter_sources dnn_filter_common.c)
    list(APPEND avfilter_sources dnn/dnn_interface.c)
    list(APPEND avfilter_sources dnn/dnn_io_proc.c)
    list(APPEND avfilter_sources dnn/queue.c)
    list(APPEND avfilter_sources dnn/safe_queue.c)
    list(APPEND avfilter_sources dnn/dnn_backend_common.c)
    # DNN backends (from DNN-OBJS-$(CONFIG_*) in dnn/Makefile)
    if(CONFIG_LIBTENSORFLOW)
        list(APPEND avfilter_sources dnn/dnn_backend_tf.c)
    endif()
    if(CONFIG_LIBOPENVINO)
        list(APPEND avfilter_sources dnn/dnn_backend_openvino.c)
    endif()
    if(CONFIG_LIBTORCH)
        list(APPEND avfilter_sources dnn/dnn_backend_torch.c)
    endif()
endif()

if(CONFIG_LIBGLSLANG)
    list(APPEND avfilter_sources vulkan_glslang.c)
endif()

if(CONFIG_LIBSHADERC)
    list(APPEND avfilter_sources vulkan_shaderc.c)
endif()

# --- Filters ---
if(CONFIG_AAP_FILTER)
    list(APPEND avfilter_sources af_aap.c)
endif()

if(CONFIG_ABENCH_FILTER)
    list(APPEND avfilter_sources f_bench.c)
endif()

if(CONFIG_ACOMPRESSOR_FILTER)
    list(APPEND avfilter_sources af_sidechaincompress.c)
endif()

if(CONFIG_ACONTRAST_FILTER)
    list(APPEND avfilter_sources af_acontrast.c)
endif()

if(CONFIG_ACOPY_FILTER)
    list(APPEND avfilter_sources af_acopy.c)
endif()

if(CONFIG_ACROSSFADE_FILTER)
    list(APPEND avfilter_sources af_afade.c)
endif()

if(CONFIG_ACROSSOVER_FILTER)
    list(APPEND avfilter_sources af_acrossover.c)
endif()

if(CONFIG_ACRUSHER_FILTER)
    list(APPEND avfilter_sources af_acrusher.c)
endif()

if(CONFIG_ACUE_FILTER)
    list(APPEND avfilter_sources f_cue.c)
endif()

if(CONFIG_ADECLICK_FILTER)
    list(APPEND avfilter_sources af_adeclick.c)
endif()

if(CONFIG_ADECLIP_FILTER)
    list(APPEND avfilter_sources af_adeclick.c)
endif()

if(CONFIG_ADECORRELATE_FILTER)
    list(APPEND avfilter_sources af_adecorrelate.c)
endif()

if(CONFIG_ADELAY_FILTER)
    list(APPEND avfilter_sources af_adelay.c)
endif()

if(CONFIG_ADENORM_FILTER)
    list(APPEND avfilter_sources af_adenorm.c)
endif()

if(CONFIG_ADERIVATIVE_FILTER)
    list(APPEND avfilter_sources af_aderivative.c)
endif()

if(CONFIG_ADRC_FILTER)
    list(APPEND avfilter_sources af_adrc.c)
endif()

if(CONFIG_ADYNAMICEQUALIZER_FILTER)
    list(APPEND avfilter_sources af_adynamicequalizer.c)
endif()

if(CONFIG_ADYNAMICSMOOTH_FILTER)
    list(APPEND avfilter_sources af_adynamicsmooth.c)
endif()

if(CONFIG_AECHO_FILTER)
    list(APPEND avfilter_sources af_aecho.c)
endif()

if(CONFIG_AEMPHASIS_FILTER)
    list(APPEND avfilter_sources af_aemphasis.c)
endif()

if(CONFIG_AEVAL_FILTER)
    list(APPEND avfilter_sources aeval.c)
endif()

if(CONFIG_AEXCITER_FILTER)
    list(APPEND avfilter_sources af_aexciter.c)
endif()

if(CONFIG_AFADE_FILTER)
    list(APPEND avfilter_sources af_afade.c)
endif()

if(CONFIG_AFFTDN_FILTER)
    list(APPEND avfilter_sources af_afftdn.c)
endif()

if(CONFIG_AFFTFILT_FILTER)
    list(APPEND avfilter_sources af_afftfilt.c)
endif()

if(CONFIG_AFIR_FILTER)
    list(APPEND avfilter_sources af_afir.c)
endif()

if(CONFIG_AFORMAT_FILTER)
    list(APPEND avfilter_sources af_aformat.c)
endif()

if(CONFIG_AFREQSHIFT_FILTER)
    list(APPEND avfilter_sources af_afreqshift.c)
endif()

if(CONFIG_AFWTDN_FILTER)
    list(APPEND avfilter_sources af_afwtdn.c)
endif()

if(CONFIG_AGATE_FILTER)
    list(APPEND avfilter_sources af_agate.c)
endif()

if(CONFIG_AIIR_FILTER)
    list(APPEND avfilter_sources af_aiir.c)
endif()

if(CONFIG_AINTEGRAL_FILTER)
    list(APPEND avfilter_sources af_aderivative.c)
endif()

if(CONFIG_AINTERLEAVE_FILTER)
    list(APPEND avfilter_sources f_interleave.c)
endif()

if(CONFIG_ALATENCY_FILTER)
    list(APPEND avfilter_sources f_latency.c)
endif()

if(CONFIG_ALIMITER_FILTER)
    list(APPEND avfilter_sources af_alimiter.c)
endif()

if(CONFIG_ALLPASS_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_ALOOP_FILTER)
    list(APPEND avfilter_sources f_loop.c)
endif()

if(CONFIG_AMERGE_FILTER)
    list(APPEND avfilter_sources af_amerge.c)
endif()

if(CONFIG_AMETADATA_FILTER)
    list(APPEND avfilter_sources f_metadata.c)
endif()

if(CONFIG_AMIX_FILTER)
    list(APPEND avfilter_sources af_amix.c)
endif()

if(CONFIG_AMULTIPLY_FILTER)
    list(APPEND avfilter_sources af_amultiply.c)
endif()

if(CONFIG_ANEQUALIZER_FILTER)
    list(APPEND avfilter_sources af_anequalizer.c)
endif()

if(CONFIG_ANLMDN_FILTER)
    list(APPEND avfilter_sources af_anlmdn.c)
endif()

if(CONFIG_ANLMF_FILTER)
    list(APPEND avfilter_sources af_anlms.c)
endif()

if(CONFIG_ANLMS_FILTER)
    list(APPEND avfilter_sources af_anlms.c)
endif()

if(CONFIG_ANULL_FILTER)
    list(APPEND avfilter_sources af_anull.c)
endif()

if(CONFIG_APAD_FILTER)
    list(APPEND avfilter_sources af_apad.c)
endif()

if(CONFIG_APERMS_FILTER)
    list(APPEND avfilter_sources f_perms.c)
endif()

if(CONFIG_APHASER_FILTER)
    list(APPEND avfilter_sources af_aphaser.c)
    list(APPEND avfilter_sources generate_wave_table.c)
endif()

if(CONFIG_APHASESHIFT_FILTER)
    list(APPEND avfilter_sources af_afreqshift.c)
endif()

if(CONFIG_APSNR_FILTER)
    list(APPEND avfilter_sources af_asdr.c)
endif()

if(CONFIG_APSYCLIP_FILTER)
    list(APPEND avfilter_sources af_apsyclip.c)
endif()

if(CONFIG_APULSATOR_FILTER)
    list(APPEND avfilter_sources af_apulsator.c)
endif()

if(CONFIG_AREALTIME_FILTER)
    list(APPEND avfilter_sources f_realtime.c)
endif()

if(CONFIG_ARESAMPLE_FILTER)
    list(APPEND avfilter_sources af_aresample.c)
endif()

if(CONFIG_AREVERSE_FILTER)
    list(APPEND avfilter_sources f_reverse.c)
endif()

if(CONFIG_ARLS_FILTER)
    list(APPEND avfilter_sources af_arls.c)
endif()

if(CONFIG_ARNNDN_FILTER)
    list(APPEND avfilter_sources af_arnndn.c)
endif()

if(CONFIG_ASDR_FILTER)
    list(APPEND avfilter_sources af_asdr.c)
endif()

if(CONFIG_ASEGMENT_FILTER)
    list(APPEND avfilter_sources f_segment.c)
endif()

if(CONFIG_ASELECT_FILTER)
    list(APPEND avfilter_sources f_select.c)
endif()

if(CONFIG_ASENDCMD_FILTER)
    list(APPEND avfilter_sources f_sendcmd.c)
endif()

if(CONFIG_ASETNSAMPLES_FILTER)
    list(APPEND avfilter_sources af_asetnsamples.c)
endif()

if(CONFIG_ASETPTS_FILTER)
    list(APPEND avfilter_sources setpts.c)
endif()

if(CONFIG_ASETRATE_FILTER)
    list(APPEND avfilter_sources af_asetrate.c)
endif()

if(CONFIG_ASETTB_FILTER)
    list(APPEND avfilter_sources settb.c)
endif()

if(CONFIG_ASHOWINFO_FILTER)
    list(APPEND avfilter_sources af_ashowinfo.c)
endif()

if(CONFIG_ASIDEDATA_FILTER)
    list(APPEND avfilter_sources f_sidedata.c)
endif()

if(CONFIG_ASISDR_FILTER)
    list(APPEND avfilter_sources af_asdr.c)
endif()

if(CONFIG_ASOFTCLIP_FILTER)
    list(APPEND avfilter_sources af_asoftclip.c)
endif()

if(CONFIG_ASPECTRALSTATS_FILTER)
    list(APPEND avfilter_sources af_aspectralstats.c)
endif()

if(CONFIG_ASPLIT_FILTER)
    list(APPEND avfilter_sources split.c)
endif()

if(CONFIG_ASR_FILTER)
    list(APPEND avfilter_sources af_asr.c)
endif()

if(CONFIG_ASTATS_FILTER)
    list(APPEND avfilter_sources af_astats.c)
endif()

if(CONFIG_ASTREAMSELECT_FILTER)
    list(APPEND avfilter_sources f_streamselect.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_ASUBBOOST_FILTER)
    list(APPEND avfilter_sources af_asubboost.c)
endif()

if(CONFIG_ASUBCUT_FILTER)
    list(APPEND avfilter_sources af_asupercut.c)
endif()

if(CONFIG_ASUPERCUT_FILTER)
    list(APPEND avfilter_sources af_asupercut.c)
endif()

if(CONFIG_ASUPERPASS_FILTER)
    list(APPEND avfilter_sources af_asupercut.c)
endif()

if(CONFIG_ASUPERSTOP_FILTER)
    list(APPEND avfilter_sources af_asupercut.c)
endif()

if(CONFIG_ATEMPO_FILTER)
    list(APPEND avfilter_sources af_atempo.c)
endif()

if(CONFIG_ATILT_FILTER)
    list(APPEND avfilter_sources af_atilt.c)
endif()

if(CONFIG_ATRIM_FILTER)
    list(APPEND avfilter_sources trim.c)
endif()

if(CONFIG_AXCORRELATE_FILTER)
    list(APPEND avfilter_sources af_axcorrelate.c)
endif()

if(CONFIG_AZMQ_FILTER)
    list(APPEND avfilter_sources f_zmq.c)
endif()

if(CONFIG_BANDPASS_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_BANDREJECT_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_BASS_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_BIQUAD_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_BS2B_FILTER)
    list(APPEND avfilter_sources af_bs2b.c)
endif()

if(CONFIG_CHANNELMAP_FILTER)
    list(APPEND avfilter_sources af_channelmap.c)
endif()

if(CONFIG_CHANNELSPLIT_FILTER)
    list(APPEND avfilter_sources af_channelsplit.c)
endif()

if(CONFIG_CHORUS_FILTER)
    list(APPEND avfilter_sources af_chorus.c)
    list(APPEND avfilter_sources generate_wave_table.c)
endif()

if(CONFIG_COMPAND_FILTER)
    list(APPEND avfilter_sources af_compand.c)
endif()

if(CONFIG_COMPENSATIONDELAY_FILTER)
    list(APPEND avfilter_sources af_compensationdelay.c)
endif()

if(CONFIG_CROSSFEED_FILTER)
    list(APPEND avfilter_sources af_crossfeed.c)
endif()

if(CONFIG_CRYSTALIZER_FILTER)
    list(APPEND avfilter_sources af_crystalizer.c)
endif()

if(CONFIG_DCSHIFT_FILTER)
    list(APPEND avfilter_sources af_dcshift.c)
endif()

if(CONFIG_DEESSER_FILTER)
    list(APPEND avfilter_sources af_deesser.c)
endif()

if(CONFIG_DIALOGUENHANCE_FILTER)
    list(APPEND avfilter_sources af_dialoguenhance.c)
endif()

if(CONFIG_DRMETER_FILTER)
    list(APPEND avfilter_sources af_drmeter.c)
endif()

if(CONFIG_DYNAUDNORM_FILTER)
    list(APPEND avfilter_sources af_dynaudnorm.c)
endif()

if(CONFIG_EARWAX_FILTER)
    list(APPEND avfilter_sources af_earwax.c)
endif()

if(CONFIG_EBUR128_FILTER)
    list(APPEND avfilter_sources f_ebur128.c)
endif()

if(CONFIG_EQUALIZER_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_EXTRASTEREO_FILTER)
    list(APPEND avfilter_sources af_extrastereo.c)
endif()

if(CONFIG_FIREQUALIZER_FILTER)
    list(APPEND avfilter_sources af_firequalizer.c)
endif()

if(CONFIG_FLANGER_FILTER)
    list(APPEND avfilter_sources af_flanger.c)
    list(APPEND avfilter_sources generate_wave_table.c)
endif()

if(CONFIG_HAAS_FILTER)
    list(APPEND avfilter_sources af_haas.c)
endif()

if(CONFIG_HDCD_FILTER)
    list(APPEND avfilter_sources af_hdcd.c)
endif()

if(CONFIG_HEADPHONE_FILTER)
    list(APPEND avfilter_sources af_headphone.c)
endif()

if(CONFIG_HIGHPASS_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_HIGHSHELF_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_JOIN_FILTER)
    list(APPEND avfilter_sources af_join.c)
endif()

if(CONFIG_LADSPA_FILTER)
    list(APPEND avfilter_sources af_ladspa.c)
endif()

if(CONFIG_LOUDNORM_FILTER)
    list(APPEND avfilter_sources af_loudnorm.c)
    list(APPEND avfilter_sources ebur128.c)
endif()

if(CONFIG_LOWPASS_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_LOWSHELF_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_LV2_FILTER)
    list(APPEND avfilter_sources af_lv2.c)
endif()

if(CONFIG_MCOMPAND_FILTER)
    list(APPEND avfilter_sources af_mcompand.c)
endif()

if(CONFIG_PAN_FILTER)
    list(APPEND avfilter_sources af_pan.c)
endif()

if(CONFIG_REPLAYGAIN_FILTER)
    list(APPEND avfilter_sources af_replaygain.c)
endif()

if(CONFIG_RUBBERBAND_FILTER)
    list(APPEND avfilter_sources af_rubberband.c)
endif()

if(CONFIG_SIDECHAINCOMPRESS_FILTER)
    list(APPEND avfilter_sources af_sidechaincompress.c)
endif()

if(CONFIG_SIDECHAINGATE_FILTER)
    list(APPEND avfilter_sources af_agate.c)
endif()

if(CONFIG_SILENCEDETECT_FILTER)
    list(APPEND avfilter_sources af_silencedetect.c)
endif()

if(CONFIG_SILENCEREMOVE_FILTER)
    list(APPEND avfilter_sources af_silenceremove.c)
endif()

if(CONFIG_SOFALIZER_FILTER)
    list(APPEND avfilter_sources af_sofalizer.c)
endif()

if(CONFIG_SPEECHNORM_FILTER)
    list(APPEND avfilter_sources af_speechnorm.c)
endif()

if(CONFIG_STEREOTOOLS_FILTER)
    list(APPEND avfilter_sources af_stereotools.c)
endif()

if(CONFIG_STEREOWIDEN_FILTER)
    list(APPEND avfilter_sources af_stereowiden.c)
endif()

if(CONFIG_SUPEREQUALIZER_FILTER)
    list(APPEND avfilter_sources af_superequalizer.c)
endif()

if(CONFIG_SURROUND_FILTER)
    list(APPEND avfilter_sources af_surround.c)
endif()

if(CONFIG_TILTSHELF_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_TREBLE_FILTER)
    list(APPEND avfilter_sources af_biquads.c)
endif()

if(CONFIG_TREMOLO_FILTER)
    list(APPEND avfilter_sources af_tremolo.c)
endif()

if(CONFIG_VIBRATO_FILTER)
    list(APPEND avfilter_sources af_vibrato.c)
    list(APPEND avfilter_sources generate_wave_table.c)
endif()

if(CONFIG_VIRTUALBASS_FILTER)
    list(APPEND avfilter_sources af_virtualbass.c)
endif()

if(CONFIG_VOLUME_FILTER)
    list(APPEND avfilter_sources af_volume.c)
endif()

if(CONFIG_VOLUMEDETECT_FILTER)
    list(APPEND avfilter_sources af_volumedetect.c)
endif()

if(CONFIG_AEVALSRC_FILTER)
    list(APPEND avfilter_sources aeval.c)
endif()

if(CONFIG_AFDELAYSRC_FILTER)
    list(APPEND avfilter_sources asrc_afdelaysrc.c)
endif()

if(CONFIG_AFIREQSRC_FILTER)
    list(APPEND avfilter_sources asrc_afirsrc.c)
endif()

if(CONFIG_AFIRSRC_FILTER)
    list(APPEND avfilter_sources asrc_afirsrc.c)
endif()

if(CONFIG_ANOISESRC_FILTER)
    list(APPEND avfilter_sources asrc_anoisesrc.c)
endif()

if(CONFIG_ANULLSRC_FILTER)
    list(APPEND avfilter_sources asrc_anullsrc.c)
endif()

if(CONFIG_FLITE_FILTER)
    list(APPEND avfilter_sources asrc_flite.c)
endif()

if(CONFIG_HILBERT_FILTER)
    list(APPEND avfilter_sources asrc_hilbert.c)
endif()

if(CONFIG_SINC_FILTER)
    list(APPEND avfilter_sources asrc_sinc.c)
endif()

if(CONFIG_SINE_FILTER)
    list(APPEND avfilter_sources asrc_sine.c)
endif()

if(CONFIG_WHISPER_FILTER)
    list(APPEND avfilter_sources af_whisper.c)
endif()

if(CONFIG_ANULLSINK_FILTER)
    list(APPEND avfilter_sources asink_anullsink.c)
endif()

if(CONFIG_ADDROI_FILTER)
    list(APPEND avfilter_sources vf_addroi.c)
endif()

if(CONFIG_ALPHAEXTRACT_FILTER)
    list(APPEND avfilter_sources vf_extractplanes.c)
endif()

if(CONFIG_ALPHAMERGE_FILTER)
    list(APPEND avfilter_sources vf_alphamerge.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_AMPLIFY_FILTER)
    list(APPEND avfilter_sources vf_amplify.c)
endif()

if(CONFIG_ASS_FILTER)
    list(APPEND avfilter_sources vf_subtitles.c)
endif()

if(CONFIG_ATADENOISE_FILTER)
    list(APPEND avfilter_sources vf_atadenoise.c)
endif()

if(CONFIG_AVGBLUR_FILTER)
    list(APPEND avfilter_sources vf_avgblur.c)
endif()

if(CONFIG_AVGBLUR_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_avgblur_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/avgblur.c)
    list(APPEND avfilter_sources boxblur.c)
endif()

if(CONFIG_AVGBLUR_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_avgblur_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_BACKGROUNDKEY_FILTER)
    list(APPEND avfilter_sources vf_backgroundkey.c)
endif()

if(CONFIG_BBOX_FILTER)
    list(APPEND avfilter_sources bbox.c)
    list(APPEND avfilter_sources vf_bbox.c)
endif()

if(CONFIG_BENCH_FILTER)
    list(APPEND avfilter_sources f_bench.c)
endif()

if(CONFIG_BILATERAL_FILTER)
    list(APPEND avfilter_sources vf_bilateral.c)
endif()

if(CONFIG_BILATERAL_CUDA_FILTER)
    list(APPEND avfilter_sources vf_bilateral_cuda.c)
    list(APPEND avfilter_sources vf_bilateral_cuda.ptx.c)
endif()

if(CONFIG_BITPLANENOISE_FILTER)
    list(APPEND avfilter_sources vf_bitplanenoise.c)
endif()

if(CONFIG_BLACKDETECT_FILTER)
    list(APPEND avfilter_sources vf_blackdetect.c)
endif()

if(CONFIG_BLACKDETECT_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_blackdetect_vulkan.c)
endif()

if(CONFIG_BLACKFRAME_FILTER)
    list(APPEND avfilter_sources vf_blackframe.c)
endif()

if(CONFIG_BLEND_FILTER)
    list(APPEND avfilter_sources vf_blend.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_BLEND_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_blend_vulkan.c)
    list(APPEND avfilter_sources framesync.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_BLOCKDETECT_FILTER)
    list(APPEND avfilter_sources vf_blockdetect.c)
endif()

if(CONFIG_BLURDETECT_FILTER)
    list(APPEND avfilter_sources vf_blurdetect.c)
    list(APPEND avfilter_sources edge_common.c)
endif()

if(CONFIG_BM3D_FILTER)
    list(APPEND avfilter_sources vf_bm3d.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_BOXBLUR_FILTER)
    list(APPEND avfilter_sources vf_boxblur.c)
    list(APPEND avfilter_sources boxblur.c)
endif()

if(CONFIG_BOXBLUR_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_avgblur_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/avgblur.c)
    list(APPEND avfilter_sources boxblur.c)
endif()

if(CONFIG_BWDIF_FILTER)
    list(APPEND avfilter_sources vf_bwdif.c)
    list(APPEND avfilter_sources bwdifdsp.c)
    list(APPEND avfilter_sources yadif_common.c)
endif()

if(CONFIG_BWDIF_CUDA_FILTER)
    list(APPEND avfilter_sources vf_bwdif_cuda.c)
    list(APPEND avfilter_sources vf_bwdif_cuda.ptx.c)
    list(APPEND avfilter_sources yadif_common.c)
endif()

if(CONFIG_BWDIF_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_bwdif_vulkan.c)
    list(APPEND avfilter_sources yadif_common.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_CAS_FILTER)
    list(APPEND avfilter_sources vf_cas.c)
endif()

if(CONFIG_CCREPACK_FILTER)
    list(APPEND avfilter_sources vf_ccrepack.c)
endif()

if(CONFIG_CHROMABER_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_chromaber_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_CHROMAHOLD_FILTER)
    list(APPEND avfilter_sources vf_chromakey.c)
endif()

if(CONFIG_CHROMAKEY_FILTER)
    list(APPEND avfilter_sources vf_chromakey.c)
endif()

if(CONFIG_CHROMAKEY_CUDA_FILTER)
    list(APPEND avfilter_sources vf_chromakey_cuda.c)
    list(APPEND avfilter_sources vf_chromakey_cuda.ptx.c)
endif()

if(CONFIG_CHROMANR_FILTER)
    list(APPEND avfilter_sources vf_chromanr.c)
endif()

if(CONFIG_CHROMASHIFT_FILTER)
    list(APPEND avfilter_sources vf_chromashift.c)
endif()

if(CONFIG_CIESCOPE_FILTER)
    list(APPEND avfilter_sources vf_ciescope.c)
endif()

if(CONFIG_CODECVIEW_FILTER)
    list(APPEND avfilter_sources vf_codecview.c)
    list(APPEND avfilter_sources qp_table.c)
endif()

if(CONFIG_COLORBALANCE_FILTER)
    list(APPEND avfilter_sources vf_colorbalance.c)
endif()

if(CONFIG_COLORCHANNELMIXER_FILTER)
    list(APPEND avfilter_sources vf_colorchannelmixer.c)
endif()

if(CONFIG_COLORCONTRAST_FILTER)
    list(APPEND avfilter_sources vf_colorcontrast.c)
endif()

if(CONFIG_COLORCORRECT_FILTER)
    list(APPEND avfilter_sources vf_colorcorrect.c)
endif()

if(CONFIG_COLORDETECT_FILTER)
    list(APPEND avfilter_sources vf_colordetect.c)
endif()

if(CONFIG_COLORIZE_FILTER)
    list(APPEND avfilter_sources vf_colorize.c)
endif()

if(CONFIG_COLORKEY_FILTER)
    list(APPEND avfilter_sources vf_colorkey.c)
endif()

if(CONFIG_COLORKEY_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_colorkey_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/colorkey.c)
endif()

if(CONFIG_COLORHOLD_FILTER)
    list(APPEND avfilter_sources vf_colorkey.c)
endif()

if(CONFIG_COLORLEVELS_FILTER)
    list(APPEND avfilter_sources vf_colorlevels.c)
endif()

if(CONFIG_COLORMAP_FILTER)
    list(APPEND avfilter_sources vf_colormap.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_COLORMATRIX_FILTER)
    list(APPEND avfilter_sources vf_colormatrix.c)
endif()

if(CONFIG_COLORSPACE_FILTER)
    list(APPEND avfilter_sources vf_colorspace.c)
    list(APPEND avfilter_sources colorspacedsp.c)
endif()

if(CONFIG_COLORSPACE_CUDA_FILTER)
    list(APPEND avfilter_sources vf_colorspace_cuda.c)
    list(APPEND avfilter_sources vf_colorspace_cuda.ptx.c)
    list(APPEND avfilter_sources cuda/load_helper.c)
endif()

if(CONFIG_COLORTEMPERATURE_FILTER)
    list(APPEND avfilter_sources vf_colortemperature.c)
endif()

if(CONFIG_CONVOLUTION_FILTER)
    list(APPEND avfilter_sources vf_convolution.c)
endif()

if(CONFIG_CONVOLUTION_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_convolution_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/convolution.c)
endif()

if(CONFIG_CONVOLVE_FILTER)
    list(APPEND avfilter_sources vf_convolve.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_COPY_FILTER)
    list(APPEND avfilter_sources vf_copy.c)
endif()

if(CONFIG_COREIMAGE_FILTER)
    list(APPEND avfilter_sources vf_coreimage.c)
endif()

if(CONFIG_CORR_FILTER)
    list(APPEND avfilter_sources vf_corr.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_COVER_RECT_FILTER)
    list(APPEND avfilter_sources vf_cover_rect.c)
    list(APPEND avfilter_sources lavfutils.c)
endif()

if(CONFIG_CROP_FILTER)
    list(APPEND avfilter_sources vf_crop.c)
endif()

if(CONFIG_CROPDETECT_FILTER)
    list(APPEND avfilter_sources vf_cropdetect.c)
    list(APPEND avfilter_sources edge_common.c)
endif()

if(CONFIG_CUE_FILTER)
    list(APPEND avfilter_sources f_cue.c)
endif()

if(CONFIG_CURVES_FILTER)
    list(APPEND avfilter_sources vf_curves.c)
endif()

if(CONFIG_DATASCOPE_FILTER)
    list(APPEND avfilter_sources vf_datascope.c)
endif()

if(CONFIG_DBLUR_FILTER)
    list(APPEND avfilter_sources vf_dblur.c)
endif()

if(CONFIG_DCTDNOIZ_FILTER)
    list(APPEND avfilter_sources vf_dctdnoiz.c)
endif()

if(CONFIG_DEBAND_FILTER)
    list(APPEND avfilter_sources vf_deband.c)
endif()

if(CONFIG_DEBLOCK_FILTER)
    list(APPEND avfilter_sources vf_deblock.c)
endif()

if(CONFIG_DECIMATE_FILTER)
    list(APPEND avfilter_sources vf_decimate.c)
endif()

if(CONFIG_DERAIN_FILTER)
    list(APPEND avfilter_sources vf_derain.c)
endif()

if(CONFIG_DECONVOLVE_FILTER)
    list(APPEND avfilter_sources vf_convolve.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_DEDOT_FILTER)
    list(APPEND avfilter_sources vf_dedot.c)
endif()

if(CONFIG_DEFLATE_FILTER)
    list(APPEND avfilter_sources vf_neighbor.c)
endif()

if(CONFIG_DEFLICKER_FILTER)
    list(APPEND avfilter_sources vf_deflicker.c)
endif()

if(CONFIG_DEINTERLACE_D3D12_FILTER)
    list(APPEND avfilter_sources vf_deinterlace_d3d12.c)
endif()

if(CONFIG_DEINTERLACE_QSV_FILTER)
    list(APPEND avfilter_sources vf_vpp_qsv.c)
endif()

if(CONFIG_DEINTERLACE_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_deinterlace_vaapi.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_DEJUDDER_FILTER)
    list(APPEND avfilter_sources vf_dejudder.c)
endif()

if(CONFIG_DELOGO_FILTER)
    list(APPEND avfilter_sources vf_delogo.c)
endif()

if(CONFIG_DENOISE_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_misc_vaapi.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_DESHAKE_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_deshake_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/deshake.c)
    list(APPEND avfilter_sources transform.c)
endif()

if(CONFIG_DESHAKE_FILTER)
    list(APPEND avfilter_sources vf_deshake.c)
    list(APPEND avfilter_sources transform.c)
endif()

if(CONFIG_DESPILL_FILTER)
    list(APPEND avfilter_sources vf_despill.c)
endif()

if(CONFIG_DETELECINE_FILTER)
    list(APPEND avfilter_sources vf_detelecine.c)
endif()

if(CONFIG_DILATION_FILTER)
    list(APPEND avfilter_sources vf_neighbor.c)
endif()

if(CONFIG_DILATION_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_neighbor_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/neighbor.c)
endif()

if(CONFIG_DISPLACE_FILTER)
    list(APPEND avfilter_sources vf_displace.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_DNN_CLASSIFY_FILTER)
    list(APPEND avfilter_sources vf_dnn_classify.c)
endif()

if(CONFIG_DNN_DETECT_FILTER)
    list(APPEND avfilter_sources vf_dnn_detect.c)
endif()

if(CONFIG_DNN_PROCESSING_FILTER)
    list(APPEND avfilter_sources vf_dnn_processing.c)
endif()

if(CONFIG_DOUBLEWEAVE_FILTER)
    list(APPEND avfilter_sources vf_weave.c)
endif()

if(CONFIG_DRAWBOX_FILTER)
    list(APPEND avfilter_sources vf_drawbox.c)
endif()

if(CONFIG_DRAWGRAPH_FILTER)
    list(APPEND avfilter_sources f_drawgraph.c)
endif()

if(CONFIG_DRAWGRID_FILTER)
    list(APPEND avfilter_sources vf_drawbox.c)
endif()

if(CONFIG_DRAWTEXT_FILTER)
    list(APPEND avfilter_sources vf_drawtext.c)
    list(APPEND avfilter_sources textutils.c)
endif()

if(CONFIG_DRAWVG_FILTER)
    list(APPEND avfilter_sources vf_drawvg.c)
    list(APPEND avfilter_sources textutils.c)
endif()

if(CONFIG_EDGEDETECT_FILTER)
    list(APPEND avfilter_sources vf_edgedetect.c)
    list(APPEND avfilter_sources edge_common.c)
endif()

if(CONFIG_ELBG_FILTER)
    list(APPEND avfilter_sources vf_elbg.c)
endif()

if(CONFIG_ENTROPY_FILTER)
    list(APPEND avfilter_sources vf_entropy.c)
endif()

if(CONFIG_EPX_FILTER)
    list(APPEND avfilter_sources vf_epx.c)
endif()

if(CONFIG_EQ_FILTER)
    list(APPEND avfilter_sources vf_eq.c)
endif()

if(CONFIG_EROSION_FILTER)
    list(APPEND avfilter_sources vf_neighbor.c)
endif()

if(CONFIG_EROSION_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_neighbor_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/neighbor.c)
endif()

if(CONFIG_ESTDIF_FILTER)
    list(APPEND avfilter_sources vf_estdif.c)
endif()

if(CONFIG_EXPOSURE_FILTER)
    list(APPEND avfilter_sources vf_exposure.c)
endif()

if(CONFIG_EXTRACTPLANES_FILTER)
    list(APPEND avfilter_sources vf_extractplanes.c)
endif()

if(CONFIG_FADE_FILTER)
    list(APPEND avfilter_sources vf_fade.c)
endif()

if(CONFIG_FEEDBACK_FILTER)
    list(APPEND avfilter_sources vf_feedback.c)
endif()

if(CONFIG_FFTDNOIZ_FILTER)
    list(APPEND avfilter_sources vf_fftdnoiz.c)
endif()

if(CONFIG_FFTFILT_FILTER)
    list(APPEND avfilter_sources vf_fftfilt.c)
endif()

if(CONFIG_FIELD_FILTER)
    list(APPEND avfilter_sources vf_field.c)
endif()

if(CONFIG_FIELDHINT_FILTER)
    list(APPEND avfilter_sources vf_fieldhint.c)
endif()

if(CONFIG_FIELDMATCH_FILTER)
    list(APPEND avfilter_sources vf_fieldmatch.c)
endif()

if(CONFIG_FIELDORDER_FILTER)
    list(APPEND avfilter_sources vf_fieldorder.c)
endif()

if(CONFIG_FILLBORDERS_FILTER)
    list(APPEND avfilter_sources vf_fillborders.c)
endif()

if(CONFIG_FIND_RECT_FILTER)
    list(APPEND avfilter_sources vf_find_rect.c)
    list(APPEND avfilter_sources lavfutils.c)
endif()

if(CONFIG_FLOODFILL_FILTER)
    list(APPEND avfilter_sources vf_floodfill.c)
endif()

if(CONFIG_FORMAT_FILTER)
    list(APPEND avfilter_sources vf_format.c)
endif()

if(CONFIG_FPS_FILTER)
    list(APPEND avfilter_sources vf_fps.c)
endif()

if(CONFIG_FRAMEPACK_FILTER)
    list(APPEND avfilter_sources vf_framepack.c)
endif()

if(CONFIG_FRAMERATE_FILTER)
    list(APPEND avfilter_sources vf_framerate.c)
endif()

if(CONFIG_FRAMESTEP_FILTER)
    list(APPEND avfilter_sources vf_framestep.c)
endif()

if(CONFIG_FREEZEDETECT_FILTER)
    list(APPEND avfilter_sources vf_freezedetect.c)
endif()

if(CONFIG_FREEZEFRAMES_FILTER)
    list(APPEND avfilter_sources vf_freezeframes.c)
endif()

if(CONFIG_FREI0R_FILTER)
    list(APPEND avfilter_sources vf_frei0r.c)
endif()

if(CONFIG_FSPP_FILTER)
    list(APPEND avfilter_sources vf_fspp.c)
    list(APPEND avfilter_sources vf_fsppdsp.c)
    list(APPEND avfilter_sources qp_table.c)
endif()

if(CONFIG_FSYNC_FILTER)
    list(APPEND avfilter_sources vf_fsync.c)
endif()

if(CONFIG_GBLUR_FILTER)
    list(APPEND avfilter_sources vf_gblur.c)
endif()

if(CONFIG_GBLUR_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_gblur_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_GEQ_FILTER)
    list(APPEND avfilter_sources vf_geq.c)
endif()

if(CONFIG_GRADFUN_FILTER)
    list(APPEND avfilter_sources vf_gradfun.c)
endif()

if(CONFIG_GRAPHMONITOR_FILTER)
    list(APPEND avfilter_sources f_graphmonitor.c)
endif()

if(CONFIG_GRAYWORLD_FILTER)
    list(APPEND avfilter_sources vf_grayworld.c)
endif()

if(CONFIG_GREYEDGE_FILTER)
    list(APPEND avfilter_sources vf_colorconstancy.c)
endif()

if(CONFIG_GUIDED_FILTER)
    list(APPEND avfilter_sources vf_guided.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_HALDCLUT_FILTER)
    list(APPEND avfilter_sources vf_lut3d.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_HFLIP_FILTER)
    list(APPEND avfilter_sources vf_hflip.c)
endif()

if(CONFIG_HFLIP_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_flip_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
endif()

if(CONFIG_HISTEQ_FILTER)
    list(APPEND avfilter_sources vf_histeq.c)
endif()

if(CONFIG_HISTOGRAM_FILTER)
    list(APPEND avfilter_sources vf_histogram.c)
endif()

if(CONFIG_HQDN3D_FILTER)
    list(APPEND avfilter_sources vf_hqdn3d.c)
endif()

if(CONFIG_HQX_FILTER)
    list(APPEND avfilter_sources vf_hqx.c)
endif()

if(CONFIG_HSTACK_FILTER)
    list(APPEND avfilter_sources vf_stack.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_HSVHOLD_FILTER)
    list(APPEND avfilter_sources vf_hsvkey.c)
endif()

if(CONFIG_HSVKEY_FILTER)
    list(APPEND avfilter_sources vf_hsvkey.c)
endif()

if(CONFIG_HUE_FILTER)
    list(APPEND avfilter_sources vf_hue.c)
endif()

if(CONFIG_HUESATURATION_FILTER)
    list(APPEND avfilter_sources vf_huesaturation.c)
endif()

if(CONFIG_HWDOWNLOAD_FILTER)
    list(APPEND avfilter_sources vf_hwdownload.c)
endif()

if(CONFIG_HWMAP_FILTER)
    list(APPEND avfilter_sources vf_hwmap.c)
endif()

if(CONFIG_HWUPLOAD_CUDA_FILTER)
    list(APPEND avfilter_sources vf_hwupload_cuda.c)
endif()

if(CONFIG_HWUPLOAD_FILTER)
    list(APPEND avfilter_sources vf_hwupload.c)
endif()

if(CONFIG_HYSTERESIS_FILTER)
    list(APPEND avfilter_sources vf_hysteresis.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_ICCDETECT_FILTER)
    list(APPEND avfilter_sources vf_iccdetect.c)
    list(APPEND avfilter_sources fflcms2.c)
endif()

if(CONFIG_ICCGEN_FILTER)
    list(APPEND avfilter_sources vf_iccgen.c)
    list(APPEND avfilter_sources fflcms2.c)
endif()

if(CONFIG_IDENTITY_FILTER)
    list(APPEND avfilter_sources vf_identity.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_IDET_FILTER)
    list(APPEND avfilter_sources vf_idet.c)
    list(APPEND avfilter_sources vf_idetdsp.c)
endif()

if(CONFIG_IL_FILTER)
    list(APPEND avfilter_sources vf_il.c)
endif()

if(CONFIG_INFLATE_FILTER)
    list(APPEND avfilter_sources vf_neighbor.c)
endif()

if(CONFIG_INTERLACE_FILTER)
    list(APPEND avfilter_sources vf_tinterlace.c)
endif()

if(CONFIG_INTERLACE_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_interlace_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_INTERLEAVE_FILTER)
    list(APPEND avfilter_sources f_interleave.c)
endif()

if(CONFIG_KERNDEINT_FILTER)
    list(APPEND avfilter_sources vf_kerndeint.c)
endif()

if(CONFIG_KIRSCH_FILTER)
    list(APPEND avfilter_sources vf_convolution.c)
endif()

if(CONFIG_LAGFUN_FILTER)
    list(APPEND avfilter_sources vf_lagfun.c)
endif()

if(CONFIG_LCEVC_FILTER)
    list(APPEND avfilter_sources vf_lcevc.c)
endif()

if(CONFIG_LATENCY_FILTER)
    list(APPEND avfilter_sources f_latency.c)
endif()

if(CONFIG_LENSCORRECTION_FILTER)
    list(APPEND avfilter_sources vf_lenscorrection.c)
endif()

if(CONFIG_LENSFUN_FILTER)
    list(APPEND avfilter_sources vf_lensfun.c)
endif()

if(CONFIG_LIBPLACEBO_FILTER)
    list(APPEND avfilter_sources vf_libplacebo.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_LIBVMAF_FILTER)
    list(APPEND avfilter_sources vf_libvmaf.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_LIBVMAF_CUDA_FILTER)
    list(APPEND avfilter_sources vf_libvmaf.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_LIMITDIFF_FILTER)
    list(APPEND avfilter_sources vf_limitdiff.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_LIMITER_FILTER)
    list(APPEND avfilter_sources vf_limiter.c)
endif()

if(CONFIG_LOOP_FILTER)
    list(APPEND avfilter_sources f_loop.c)
endif()

if(CONFIG_LUMAKEY_FILTER)
    list(APPEND avfilter_sources vf_lumakey.c)
endif()

if(CONFIG_LUT1D_FILTER)
    list(APPEND avfilter_sources vf_lut3d.c)
endif()

if(CONFIG_LUT_FILTER)
    list(APPEND avfilter_sources vf_lut.c)
endif()

if(CONFIG_LUT2_FILTER)
    list(APPEND avfilter_sources vf_lut2.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_LUT3D_FILTER)
    list(APPEND avfilter_sources vf_lut3d.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_LUTRGB_FILTER)
    list(APPEND avfilter_sources vf_lut.c)
endif()

if(CONFIG_LUTYUV_FILTER)
    list(APPEND avfilter_sources vf_lut.c)
endif()

if(CONFIG_MASKEDCLAMP_FILTER)
    list(APPEND avfilter_sources vf_maskedclamp.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_MASKEDMAX_FILTER)
    list(APPEND avfilter_sources vf_maskedminmax.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_MASKEDMERGE_FILTER)
    list(APPEND avfilter_sources vf_maskedmerge.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_MASKEDMIN_FILTER)
    list(APPEND avfilter_sources vf_maskedminmax.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_MASKEDTHRESHOLD_FILTER)
    list(APPEND avfilter_sources vf_maskedthreshold.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_MASKFUN_FILTER)
    list(APPEND avfilter_sources vf_maskfun.c)
endif()

if(CONFIG_MCDEINT_FILTER)
    list(APPEND avfilter_sources vf_mcdeint.c)
endif()

if(CONFIG_MEDIAN_FILTER)
    list(APPEND avfilter_sources vf_median.c)
endif()

if(CONFIG_MERGEPLANES_FILTER)
    list(APPEND avfilter_sources vf_mergeplanes.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_MESTIMATE_FILTER)
    list(APPEND avfilter_sources vf_mestimate.c)
    list(APPEND avfilter_sources motion_estimation.c)
endif()

if(CONFIG_MESTIMATE_D3D12_FILTER)
    list(APPEND avfilter_sources vf_mestimate_d3d12.c)
endif()

if(CONFIG_METADATA_FILTER)
    list(APPEND avfilter_sources f_metadata.c)
endif()

if(CONFIG_MIDEQUALIZER_FILTER)
    list(APPEND avfilter_sources vf_midequalizer.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_MINTERPOLATE_FILTER)
    list(APPEND avfilter_sources vf_minterpolate.c)
    list(APPEND avfilter_sources motion_estimation.c)
endif()

if(CONFIG_MIX_FILTER)
    list(APPEND avfilter_sources vf_mix.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_MONOCHROME_FILTER)
    list(APPEND avfilter_sources vf_monochrome.c)
endif()

if(CONFIG_MORPHO_FILTER)
    list(APPEND avfilter_sources vf_morpho.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_MPDECIMATE_FILTER)
    list(APPEND avfilter_sources vf_mpdecimate.c)
endif()

if(CONFIG_MSAD_FILTER)
    list(APPEND avfilter_sources vf_identity.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_MULTIPLY_FILTER)
    list(APPEND avfilter_sources vf_multiply.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_NEGATE_FILTER)
    list(APPEND avfilter_sources vf_negate.c)
endif()

if(CONFIG_NLMEANS_FILTER)
    list(APPEND avfilter_sources vf_nlmeans.c)
endif()

if(CONFIG_NLMEANS_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_nlmeans_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/nlmeans.c)
endif()

if(CONFIG_NLMEANS_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_nlmeans_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_NNEDI_FILTER)
    list(APPEND avfilter_sources vf_nnedi.c)
endif()

if(CONFIG_NOFORMAT_FILTER)
    list(APPEND avfilter_sources vf_format.c)
endif()

if(CONFIG_NOISE_FILTER)
    list(APPEND avfilter_sources vf_noise.c)
endif()

if(CONFIG_NORMALIZE_FILTER)
    list(APPEND avfilter_sources vf_normalize.c)
endif()

if(CONFIG_NULL_FILTER)
    list(APPEND avfilter_sources vf_null.c)
endif()

if(CONFIG_OCR_FILTER)
    list(APPEND avfilter_sources vf_ocr.c)
endif()

if(CONFIG_OCV_FILTER)
    list(APPEND avfilter_sources vf_libopencv.c)
endif()

if(CONFIG_OCIO_FILTER)
    list(APPEND avfilter_sources vf_opencolorio.c)
    list(APPEND avfilter_sources ocio_wrapper.c)
endif()

if(CONFIG_OSCILLOSCOPE_FILTER)
    list(APPEND avfilter_sources vf_datascope.c)
endif()

if(CONFIG_OVERLAY_FILTER)
    list(APPEND avfilter_sources vf_overlay.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_OVERLAY_CUDA_FILTER)
    list(APPEND avfilter_sources vf_overlay_cuda.c)
    list(APPEND avfilter_sources framesync.c)
    list(APPEND avfilter_sources vf_overlay_cuda.ptx.c)
    list(APPEND avfilter_sources cuda/load_helper.c)
endif()

if(CONFIG_OVERLAY_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_overlay_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/overlay.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_OVERLAY_QSV_FILTER)
    list(APPEND avfilter_sources vf_overlay_qsv.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_OVERLAY_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_overlay_vaapi.c)
    list(APPEND avfilter_sources framesync.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_OVERLAY_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_overlay_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_OWDENOISE_FILTER)
    list(APPEND avfilter_sources vf_owdenoise.c)
endif()

if(CONFIG_PAD_FILTER)
    list(APPEND avfilter_sources vf_pad.c)
endif()

if(CONFIG_PAD_CUDA_FILTER)
    list(APPEND avfilter_sources vf_pad_cuda.c)
    list(APPEND avfilter_sources vf_pad_cuda.ptx.c)
    list(APPEND avfilter_sources cuda/load_helper.c)
endif()

if(CONFIG_PAD_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_pad_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/pad.c)
endif()

if(CONFIG_PALETTEGEN_FILTER)
    list(APPEND avfilter_sources vf_palettegen.c)
    list(APPEND avfilter_sources palette.c)
endif()

if(CONFIG_PALETTEUSE_FILTER)
    list(APPEND avfilter_sources vf_paletteuse.c)
    list(APPEND avfilter_sources framesync.c)
    list(APPEND avfilter_sources palette.c)
endif()

if(CONFIG_PERMS_FILTER)
    list(APPEND avfilter_sources f_perms.c)
endif()

if(CONFIG_PERSPECTIVE_FILTER)
    list(APPEND avfilter_sources vf_perspective.c)
endif()

if(CONFIG_PHASE_FILTER)
    list(APPEND avfilter_sources vf_phase.c)
endif()

if(CONFIG_PHOTOSENSITIVITY_FILTER)
    list(APPEND avfilter_sources vf_photosensitivity.c)
endif()

if(CONFIG_PIXDESCTEST_FILTER)
    list(APPEND avfilter_sources vf_pixdesctest.c)
endif()

if(CONFIG_PIXELIZE_FILTER)
    list(APPEND avfilter_sources vf_pixelize.c)
endif()

if(CONFIG_PIXSCOPE_FILTER)
    list(APPEND avfilter_sources vf_datascope.c)
endif()

if(CONFIG_PP7_FILTER)
    list(APPEND avfilter_sources vf_pp7.c)
    list(APPEND avfilter_sources qp_table.c)
endif()

if(CONFIG_PREMULTIPLY_DYNAMIC_FILTER)
    list(APPEND avfilter_sources vf_premultiply.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_PREMULTIPLY_FILTER)
    list(APPEND avfilter_sources vf_premultiply.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_PREWITT_FILTER)
    list(APPEND avfilter_sources vf_convolution.c)
endif()

if(CONFIG_PREWITT_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_convolution_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/convolution.c)
endif()

if(CONFIG_PROCAMP_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_procamp_vaapi.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_PROGRAM_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_program_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_PSEUDOCOLOR_FILTER)
    list(APPEND avfilter_sources vf_pseudocolor.c)
endif()

if(CONFIG_PSNR_FILTER)
    list(APPEND avfilter_sources vf_psnr.c)
    list(APPEND avfilter_sources framesync.c)
    list(APPEND avfilter_sources psnr.c)
endif()

if(CONFIG_PULLUP_FILTER)
    list(APPEND avfilter_sources vf_pullup.c)
endif()

if(CONFIG_QP_FILTER)
    list(APPEND avfilter_sources vf_qp.c)
endif()

if(CONFIG_QUIRC_FILTER)
    list(APPEND avfilter_sources vf_quirc.c)
endif()

if(CONFIG_RANDOM_FILTER)
    list(APPEND avfilter_sources vf_random.c)
endif()

if(CONFIG_READEIA608_FILTER)
    list(APPEND avfilter_sources vf_readeia608.c)
endif()

if(CONFIG_READVITC_FILTER)
    list(APPEND avfilter_sources vf_readvitc.c)
endif()

if(CONFIG_REALTIME_FILTER)
    list(APPEND avfilter_sources f_realtime.c)
endif()

if(CONFIG_REMAP_FILTER)
    list(APPEND avfilter_sources vf_remap.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_REMAP_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_remap_opencl.c)
    list(APPEND avfilter_sources framesync.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/remap.c)
endif()

if(CONFIG_REMOVEGRAIN_FILTER)
    list(APPEND avfilter_sources vf_removegrain.c)
endif()

if(CONFIG_REMOVELOGO_FILTER)
    list(APPEND avfilter_sources bbox.c)
    list(APPEND avfilter_sources lswsutils.c)
    list(APPEND avfilter_sources lavfutils.c)
    list(APPEND avfilter_sources vf_removelogo.c)
endif()

if(CONFIG_REPEATFIELDS_FILTER)
    list(APPEND avfilter_sources vf_repeatfields.c)
endif()

if(CONFIG_REVERSE_FILTER)
    list(APPEND avfilter_sources f_reverse.c)
endif()

if(CONFIG_RGBASHIFT_FILTER)
    list(APPEND avfilter_sources vf_chromashift.c)
endif()

if(CONFIG_ROBERTS_FILTER)
    list(APPEND avfilter_sources vf_convolution.c)
endif()

if(CONFIG_ROBERTS_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_convolution_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/convolution.c)
endif()

if(CONFIG_ROTATE_FILTER)
    list(APPEND avfilter_sources vf_rotate.c)
endif()

if(CONFIG_SAB_FILTER)
    list(APPEND avfilter_sources vf_sab.c)
endif()

if(CONFIG_SCALE_FILTER)
    list(APPEND avfilter_sources vf_scale.c)
    list(APPEND avfilter_sources scale_eval.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_SCALE_D3D11_FILTER)
    list(APPEND avfilter_sources vf_scale_d3d11.c)
    list(APPEND avfilter_sources scale_eval.c)
endif()

if(CONFIG_SCALE_D3D12_FILTER)
    list(APPEND avfilter_sources vf_scale_d3d12.c)
    list(APPEND avfilter_sources scale_eval.c)
endif()

if(CONFIG_SCALE_CUDA_FILTER)
    list(APPEND avfilter_sources vf_scale_cuda.c)
    list(APPEND avfilter_sources scale_eval.c)
    list(APPEND avfilter_sources vf_scale_cuda.ptx.c)
    list(APPEND avfilter_sources cuda/load_helper.c)
endif()

if(CONFIG_SCALE_NPP_FILTER)
    list(APPEND avfilter_sources vf_scale_npp.c)
    list(APPEND avfilter_sources scale_eval.c)
endif()

if(CONFIG_SCALE_QSV_FILTER)
    list(APPEND avfilter_sources vf_vpp_qsv.c)
endif()

if(CONFIG_SCALE_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_scale_vaapi.c)
    list(APPEND avfilter_sources scale_eval.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_SCALE_VT_FILTER)
    list(APPEND avfilter_sources vf_scale_vt.c)
    list(APPEND avfilter_sources scale_eval.c)
endif()

if(CONFIG_SCALE_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_scale_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_SCALE2REF_FILTER)
    list(APPEND avfilter_sources vf_scale.c)
    list(APPEND avfilter_sources scale_eval.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_SCALE2REF_NPP_FILTER)
    list(APPEND avfilter_sources vf_scale_npp.c)
    list(APPEND avfilter_sources scale_eval.c)
endif()

if(CONFIG_SCDET_FILTER)
    list(APPEND avfilter_sources vf_scdet.c)
endif()

if(CONFIG_SCDET_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_scdet_vulkan.c)
endif()

if(CONFIG_SCHARR_FILTER)
    list(APPEND avfilter_sources vf_convolution.c)
endif()

if(CONFIG_SCROLL_FILTER)
    list(APPEND avfilter_sources vf_scroll.c)
endif()

if(CONFIG_SEGMENT_FILTER)
    list(APPEND avfilter_sources f_segment.c)
endif()

if(CONFIG_SELECT_FILTER)
    list(APPEND avfilter_sources f_select.c)
endif()

if(CONFIG_SELECTIVECOLOR_FILTER)
    list(APPEND avfilter_sources vf_selectivecolor.c)
endif()

if(CONFIG_SENDCMD_FILTER)
    list(APPEND avfilter_sources f_sendcmd.c)
endif()

if(CONFIG_SEPARATEFIELDS_FILTER)
    list(APPEND avfilter_sources vf_separatefields.c)
endif()

if(CONFIG_SETDAR_FILTER)
    list(APPEND avfilter_sources vf_aspect.c)
endif()

if(CONFIG_SETFIELD_FILTER)
    list(APPEND avfilter_sources vf_setparams.c)
endif()

if(CONFIG_SETPARAMS_FILTER)
    list(APPEND avfilter_sources vf_setparams.c)
endif()

if(CONFIG_SETPTS_FILTER)
    list(APPEND avfilter_sources setpts.c)
endif()

if(CONFIG_SETRANGE_FILTER)
    list(APPEND avfilter_sources vf_setparams.c)
endif()

if(CONFIG_SETSAR_FILTER)
    list(APPEND avfilter_sources vf_aspect.c)
endif()

if(CONFIG_SETTB_FILTER)
    list(APPEND avfilter_sources settb.c)
endif()

if(CONFIG_SHARPEN_NPP_FILTER)
    list(APPEND avfilter_sources vf_sharpen_npp.c)
endif()

if(CONFIG_SHARPNESS_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_misc_vaapi.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_SHEAR_FILTER)
    list(APPEND avfilter_sources vf_shear.c)
endif()

if(CONFIG_SHOWINFO_FILTER)
    list(APPEND avfilter_sources vf_showinfo.c)
endif()

if(CONFIG_SHOWPALETTE_FILTER)
    list(APPEND avfilter_sources vf_showpalette.c)
endif()

if(CONFIG_SHUFFLEFRAMES_FILTER)
    list(APPEND avfilter_sources vf_shuffleframes.c)
endif()

if(CONFIG_SHUFFLEPIXELS_FILTER)
    list(APPEND avfilter_sources vf_shufflepixels.c)
endif()

if(CONFIG_SHUFFLEPLANES_FILTER)
    list(APPEND avfilter_sources vf_shuffleplanes.c)
endif()

if(CONFIG_SIDEDATA_FILTER)
    list(APPEND avfilter_sources f_sidedata.c)
endif()

if(CONFIG_SIGNALSTATS_FILTER)
    list(APPEND avfilter_sources vf_signalstats.c)
endif()

if(CONFIG_SIGNATURE_FILTER)
    list(APPEND avfilter_sources vf_signature.c)
endif()

if(CONFIG_SMARTBLUR_FILTER)
    list(APPEND avfilter_sources vf_smartblur.c)
endif()

if(CONFIG_SOBEL_FILTER)
    list(APPEND avfilter_sources vf_convolution.c)
endif()

if(CONFIG_SOBEL_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_convolution_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/convolution.c)
endif()

if(CONFIG_SITI_FILTER)
    list(APPEND avfilter_sources vf_siti.c)
endif()

if(CONFIG_SPLIT_FILTER)
    list(APPEND avfilter_sources split.c)
endif()

if(CONFIG_SPP_FILTER)
    list(APPEND avfilter_sources vf_spp.c)
    list(APPEND avfilter_sources qp_table.c)
endif()

if(CONFIG_SR_FILTER)
    list(APPEND avfilter_sources vf_sr.c)
endif()

if(CONFIG_SR_AMF_FILTER)
    list(APPEND avfilter_sources vf_sr_amf.c)
    list(APPEND avfilter_sources scale_eval.c)
    list(APPEND avfilter_sources vf_amf_common.c)
endif()

if(CONFIG_SSIM_FILTER)
    list(APPEND avfilter_sources vf_ssim.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_SSIM360_FILTER)
    list(APPEND avfilter_sources vf_ssim360.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_STEREO3D_FILTER)
    list(APPEND avfilter_sources vf_stereo3d.c)
endif()

if(CONFIG_STREAMSELECT_FILTER)
    list(APPEND avfilter_sources f_streamselect.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_SUBTITLES_FILTER)
    list(APPEND avfilter_sources vf_subtitles.c)
endif()

if(CONFIG_SUPER2XSAI_FILTER)
    list(APPEND avfilter_sources vf_super2xsai.c)
endif()

if(CONFIG_SWAPRECT_FILTER)
    list(APPEND avfilter_sources vf_swaprect.c)
endif()

if(CONFIG_SWAPUV_FILTER)
    list(APPEND avfilter_sources vf_swapuv.c)
endif()

if(CONFIG_TBLEND_FILTER)
    list(APPEND avfilter_sources vf_blend.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_TELECINE_FILTER)
    list(APPEND avfilter_sources vf_telecine.c)
endif()

if(CONFIG_THISTOGRAM_FILTER)
    list(APPEND avfilter_sources vf_histogram.c)
endif()

if(CONFIG_THRESHOLD_FILTER)
    list(APPEND avfilter_sources vf_threshold.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_THUMBNAIL_FILTER)
    list(APPEND avfilter_sources vf_thumbnail.c)
endif()

if(CONFIG_THUMBNAIL_CUDA_FILTER)
    list(APPEND avfilter_sources vf_thumbnail_cuda.c)
    list(APPEND avfilter_sources vf_thumbnail_cuda.ptx.c)
    list(APPEND avfilter_sources cuda/load_helper.c)
endif()

if(CONFIG_TILE_FILTER)
    list(APPEND avfilter_sources vf_tile.c)
endif()

if(CONFIG_TILTANDSHIFT_FILTER)
    list(APPEND avfilter_sources vf_tiltandshift.c)
endif()

if(CONFIG_TINTERLACE_FILTER)
    list(APPEND avfilter_sources vf_tinterlace.c)
endif()

if(CONFIG_TLUT2_FILTER)
    list(APPEND avfilter_sources vf_lut2.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_TMEDIAN_FILTER)
    list(APPEND avfilter_sources vf_xmedian.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_TMIDEQUALIZER_FILTER)
    list(APPEND avfilter_sources vf_tmidequalizer.c)
endif()

if(CONFIG_TMIX_FILTER)
    list(APPEND avfilter_sources vf_mix.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_TONEMAP_FILTER)
    list(APPEND avfilter_sources vf_tonemap.c)
endif()

if(CONFIG_TONEMAP_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_tonemap_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/tonemap.c)
    list(APPEND avfilter_sources opencl/colorspace_common.c)
endif()

if(CONFIG_TONEMAP_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_tonemap_vaapi.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_TPAD_FILTER)
    list(APPEND avfilter_sources vf_tpad.c)
endif()

if(CONFIG_TRANSPOSE_FILTER)
    list(APPEND avfilter_sources vf_transpose.c)
endif()

if(CONFIG_TRANSPOSE_NPP_FILTER)
    list(APPEND avfilter_sources vf_transpose_npp.c)
endif()

if(CONFIG_TRANSPOSE_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_transpose_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/transpose.c)
endif()

if(CONFIG_TRANSPOSE_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_transpose_vaapi.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_TRANSPOSE_VT_FILTER)
    list(APPEND avfilter_sources vf_transpose_vt.c)
endif()

if(CONFIG_TRANSPOSE_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_transpose_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_TRIM_FILTER)
    list(APPEND avfilter_sources trim.c)
endif()

if(CONFIG_UNPREMULTIPLY_FILTER)
    list(APPEND avfilter_sources vf_premultiply.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_UNSHARP_FILTER)
    list(APPEND avfilter_sources vf_unsharp.c)
endif()

if(CONFIG_UNSHARP_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_unsharp_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/unsharp.c)
endif()

if(CONFIG_UNTILE_FILTER)
    list(APPEND avfilter_sources vf_untile.c)
endif()

if(CONFIG_USPP_FILTER)
    list(APPEND avfilter_sources vf_uspp.c)
    list(APPEND avfilter_sources qp_table.c)
endif()

if(CONFIG_V360_FILTER)
    list(APPEND avfilter_sources vf_v360.c)
endif()

if(CONFIG_VAGUEDENOISER_FILTER)
    list(APPEND avfilter_sources vf_vaguedenoiser.c)
endif()

if(CONFIG_VARBLUR_FILTER)
    list(APPEND avfilter_sources vf_varblur.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_VECTORSCOPE_FILTER)
    list(APPEND avfilter_sources vf_vectorscope.c)
endif()

if(CONFIG_VFLIP_FILTER)
    list(APPEND avfilter_sources vf_vflip.c)
endif()

if(CONFIG_VFLIP_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_flip_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
endif()

if(CONFIG_VFRDET_FILTER)
    list(APPEND avfilter_sources vf_vfrdet.c)
endif()

if(CONFIG_VIBRANCE_FILTER)
    list(APPEND avfilter_sources vf_vibrance.c)
endif()

if(CONFIG_VIDSTABDETECT_FILTER)
    list(APPEND avfilter_sources vidstabutils.c)
    list(APPEND avfilter_sources vf_vidstabdetect.c)
endif()

if(CONFIG_VIDSTABTRANSFORM_FILTER)
    list(APPEND avfilter_sources vidstabutils.c)
    list(APPEND avfilter_sources vf_vidstabtransform.c)
endif()

if(CONFIG_VIF_FILTER)
    list(APPEND avfilter_sources vf_vif.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_VIGNETTE_FILTER)
    list(APPEND avfilter_sources vf_vignette.c)
endif()

if(CONFIG_VMAFMOTION_FILTER)
    list(APPEND avfilter_sources vf_vmafmotion.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_VPP_AMF_FILTER)
    list(APPEND avfilter_sources vf_vpp_amf.c)
    list(APPEND avfilter_sources scale_eval.c)
    list(APPEND avfilter_sources vf_amf_common.c)
endif()

if(CONFIG_VPP_QSV_FILTER)
    list(APPEND avfilter_sources vf_vpp_qsv.c)
endif()

if(CONFIG_VSTACK_FILTER)
    list(APPEND avfilter_sources vf_stack.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_W3FDIF_FILTER)
    list(APPEND avfilter_sources vf_w3fdif.c)
endif()

if(CONFIG_WAVEFORM_FILTER)
    list(APPEND avfilter_sources vf_waveform.c)
endif()

if(CONFIG_WEAVE_FILTER)
    list(APPEND avfilter_sources vf_weave.c)
endif()

if(CONFIG_XBR_FILTER)
    list(APPEND avfilter_sources vf_xbr.c)
endif()

if(CONFIG_XCORRELATE_FILTER)
    list(APPEND avfilter_sources vf_convolve.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_XFADE_FILTER)
    list(APPEND avfilter_sources vf_xfade.c)
endif()

if(CONFIG_XFADE_OPENCL_FILTER)
    list(APPEND avfilter_sources vf_xfade_opencl.c)
    list(APPEND avfilter_sources opencl.c)
    list(APPEND avfilter_sources opencl/xfade.c)
endif()

if(CONFIG_XFADE_VULKAN_FILTER)
    list(APPEND avfilter_sources vf_xfade_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_XMEDIAN_FILTER)
    list(APPEND avfilter_sources vf_xmedian.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_XPSNR_FILTER)
    list(APPEND avfilter_sources vf_xpsnr.c)
    list(APPEND avfilter_sources framesync.c)
    list(APPEND avfilter_sources psnr.c)
endif()

if(CONFIG_XSTACK_FILTER)
    list(APPEND avfilter_sources vf_stack.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_YADIF_FILTER)
    list(APPEND avfilter_sources vf_yadif.c)
    list(APPEND avfilter_sources yadif_common.c)
endif()

if(CONFIG_YADIF_CUDA_FILTER)
    list(APPEND avfilter_sources vf_yadif_cuda.c)
    list(APPEND avfilter_sources vf_yadif_cuda.ptx.c)
    list(APPEND avfilter_sources yadif_common.c)
    list(APPEND avfilter_sources cuda/load_helper.c)
endif()

if(CONFIG_YADIF_VIDEOTOOLBOX_FILTER)
    list(APPEND avfilter_sources vf_yadif_videotoolbox.c)
    list(APPEND avfilter_sources metal/vf_yadif_videotoolbox.metallib.c)
    list(APPEND avfilter_sources metal/utils.c)
    list(APPEND avfilter_sources yadif_common.c)
endif()

if(CONFIG_YAEPBLUR_FILTER)
    list(APPEND avfilter_sources vf_yaepblur.c)
endif()

if(CONFIG_ZMQ_FILTER)
    list(APPEND avfilter_sources f_zmq.c)
endif()

if(CONFIG_ZOOMPAN_FILTER)
    list(APPEND avfilter_sources vf_zoompan.c)
endif()

if(CONFIG_ZSCALE_FILTER)
    list(APPEND avfilter_sources vf_zscale.c)
endif()

if(CONFIG_HSTACK_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_stack_vaapi.c)
    list(APPEND avfilter_sources framesync.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_VSTACK_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_stack_vaapi.c)
    list(APPEND avfilter_sources framesync.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_XSTACK_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_stack_vaapi.c)
    list(APPEND avfilter_sources framesync.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_HSTACK_QSV_FILTER)
    list(APPEND avfilter_sources vf_stack_qsv.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_VSTACK_QSV_FILTER)
    list(APPEND avfilter_sources vf_stack_qsv.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_XSTACK_QSV_FILTER)
    list(APPEND avfilter_sources vf_stack_qsv.c)
    list(APPEND avfilter_sources framesync.c)
endif()

if(CONFIG_PAD_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_pad_vaapi.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_DRAWBOX_VAAPI_FILTER)
    list(APPEND avfilter_sources vf_drawbox_vaapi.c)
    list(APPEND avfilter_sources vaapi_vpp.c)
endif()

if(CONFIG_ALLRGB_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_ALLYUV_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_CELLAUTO_FILTER)
    list(APPEND avfilter_sources vsrc_cellauto.c)
endif()

if(CONFIG_COLOR_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_COLORCHART_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_COLORSPECTRUM_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_COREIMAGESRC_FILTER)
    list(APPEND avfilter_sources vf_coreimage.c)
endif()

if(CONFIG_DDAGRAB_FILTER)
    list(APPEND avfilter_sources vsrc_ddagrab.c)
endif()

if(CONFIG_FREI0R_SRC_FILTER)
    list(APPEND avfilter_sources vf_frei0r.c)
endif()

if(CONFIG_GFXCAPTURE_FILTER)
    list(APPEND avfilter_sources vsrc_gfxcapture.c)
    list(APPEND avfilter_sources vsrc_gfxcapture_winrt.c)
endif()

if(CONFIG_GRADIENTS_FILTER)
    list(APPEND avfilter_sources vsrc_gradients.c)
endif()

if(CONFIG_HALDCLUTSRC_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_LIFE_FILTER)
    list(APPEND avfilter_sources vsrc_life.c)
endif()

if(CONFIG_MANDELBROT_FILTER)
    list(APPEND avfilter_sources vsrc_mandelbrot.c)
endif()

if(CONFIG_MPTESTSRC_FILTER)
    list(APPEND avfilter_sources vsrc_mptestsrc.c)
endif()

if(CONFIG_NULLSRC_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_OPENCLSRC_FILTER)
    list(APPEND avfilter_sources vf_program_opencl.c)
    list(APPEND avfilter_sources opencl.c)
endif()

if(CONFIG_PAL75BARS_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_PAL100BARS_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_PERLIN_FILTER)
    list(APPEND avfilter_sources vsrc_perlin.c)
    list(APPEND avfilter_sources perlin.c)
endif()

if(CONFIG_QRENCODE_FILTER)
    list(APPEND avfilter_sources qrencode.c)
    list(APPEND avfilter_sources textutils.c)
endif()

if(CONFIG_QRENCODESRC_FILTER)
    list(APPEND avfilter_sources qrencode.c)
    list(APPEND avfilter_sources textutils.c)
endif()

if(CONFIG_RGBTESTSRC_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_SIERPINSKI_FILTER)
    list(APPEND avfilter_sources vsrc_sierpinski.c)
endif()

if(CONFIG_SMPTEBARS_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_SMPTEHDBARS_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_COLOR_VULKAN_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc_vulkan.c)
    list(APPEND avfilter_sources vulkan.c)
    list(APPEND avfilter_sources vulkan_filter.c)
endif()

if(CONFIG_TESTSRC_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_TESTSRC2_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_AMF_CAPTURE_FILTER)
    list(APPEND avfilter_sources vsrc_amf.c)
endif()

if(CONFIG_YUVTESTSRC_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_ZONEPLATE_FILTER)
    list(APPEND avfilter_sources vsrc_testsrc.c)
endif()

if(CONFIG_NULLSINK_FILTER)
    list(APPEND avfilter_sources vsink_nullsink.c)
endif()

if(CONFIG_A3DSCOPE_FILTER)
    list(APPEND avfilter_sources avf_a3dscope.c)
endif()

if(CONFIG_ABITSCOPE_FILTER)
    list(APPEND avfilter_sources avf_abitscope.c)
endif()

if(CONFIG_ADRAWGRAPH_FILTER)
    list(APPEND avfilter_sources f_drawgraph.c)
endif()

if(CONFIG_AGRAPHMONITOR_FILTER)
    list(APPEND avfilter_sources f_graphmonitor.c)
endif()

if(CONFIG_AHISTOGRAM_FILTER)
    list(APPEND avfilter_sources avf_ahistogram.c)
endif()

if(CONFIG_APHASEMETER_FILTER)
    list(APPEND avfilter_sources avf_aphasemeter.c)
endif()

if(CONFIG_AVECTORSCOPE_FILTER)
    list(APPEND avfilter_sources avf_avectorscope.c)
endif()

if(CONFIG_CONCAT_FILTER)
    list(APPEND avfilter_sources avf_concat.c)
endif()

if(CONFIG_SHOWCQT_FILTER)
    list(APPEND avfilter_sources avf_showcqt.c)
    list(APPEND avfilter_sources lswsutils.c)
    list(APPEND avfilter_sources lavfutils.c)
endif()

if(CONFIG_SHOWCWT_FILTER)
    list(APPEND avfilter_sources avf_showcwt.c)
endif()

if(CONFIG_SHOWFREQS_FILTER)
    list(APPEND avfilter_sources avf_showfreqs.c)
endif()

if(CONFIG_SHOWSPATIAL_FILTER)
    list(APPEND avfilter_sources avf_showspatial.c)
endif()

if(CONFIG_SHOWSPECTRUM_FILTER)
    list(APPEND avfilter_sources avf_showspectrum.c)
endif()

if(CONFIG_SHOWSPECTRUMPIC_FILTER)
    list(APPEND avfilter_sources avf_showspectrum.c)
endif()

if(CONFIG_SHOWVOLUME_FILTER)
    list(APPEND avfilter_sources avf_showvolume.c)
endif()

if(CONFIG_SHOWWAVES_FILTER)
    list(APPEND avfilter_sources avf_showwaves.c)
endif()

if(CONFIG_SHOWWAVESPIC_FILTER)
    list(APPEND avfilter_sources avf_showwaves.c)
endif()

if(CONFIG_SPECTRUMSYNTH_FILTER)
    list(APPEND avfilter_sources vaf_spectrumsynth.c)
endif()

if(CONFIG_AVSYNCTEST_FILTER)
    list(APPEND avfilter_sources src_avsynctest.c)
endif()

if(CONFIG_AMOVIE_FILTER)
    list(APPEND avfilter_sources src_movie.c)
endif()

if(CONFIG_MOVIE_FILTER)
    list(APPEND avfilter_sources src_movie.c)
endif()

# ============================================================================
# x86 architecture-specific sources
# ============================================================================
if(ARCH_X86 AND ENABLE_ASM)

    # x86 C sources (conditional)
    if(CONFIG_NOISE_FILTER)
        list(APPEND avfilter_sources x86/vf_noise.c)
    endif()

    if(CONFIG_SPP_FILTER)
        list(APPEND avfilter_sources x86/vf_spp.c)
    endif()

    if(HAVE_X86ASM)
        # x86 ASM sources (conditional, require NASM/YASM)
        if(CONFIG_SCENE_SAD)
            list(APPEND avfilter_sources x86/scene_sad.asm)
            list(APPEND avfilter_sources x86/scene_sad_init.c)
        endif()

        if(CONFIG_AFIR_FILTER)
            list(APPEND avfilter_sources x86/af_afir.asm)
            list(APPEND avfilter_sources x86/af_afir_init.c)
        endif()

        if(CONFIG_ANLMDN_FILTER)
            list(APPEND avfilter_sources x86/af_anlmdn.asm)
            list(APPEND avfilter_sources x86/af_anlmdn_init.c)
        endif()

        if(CONFIG_ATADENOISE_FILTER)
            list(APPEND avfilter_sources x86/vf_atadenoise.asm)
            list(APPEND avfilter_sources x86/vf_atadenoise_init.c)
        endif()

        if(CONFIG_BLACKDETECT_FILTER)
            list(APPEND avfilter_sources x86/vf_blackdetect.asm)
            list(APPEND avfilter_sources x86/vf_blackdetect_init.c)
        endif()

        if(CONFIG_BLEND_FILTER)
            list(APPEND avfilter_sources x86/vf_blend.asm)
            list(APPEND avfilter_sources x86/vf_blend_init.c)
        endif()

        if(CONFIG_BWDIF_FILTER)
            list(APPEND avfilter_sources x86/vf_bwdif.asm)
            list(APPEND avfilter_sources x86/vf_bwdif_init.c)
        endif()

        if(CONFIG_COLORDETECT_FILTER)
            list(APPEND avfilter_sources x86/vf_colordetect.asm)
            list(APPEND avfilter_sources x86/vf_colordetect_init.c)
        endif()

        if(CONFIG_COLORSPACE_FILTER)
            list(APPEND avfilter_sources x86/colorspacedsp.asm)
            list(APPEND avfilter_sources x86/colorspacedsp_init.c)
        endif()

        if(CONFIG_CONVOLUTION_FILTER)
            list(APPEND avfilter_sources x86/vf_convolution.asm)
            list(APPEND avfilter_sources x86/vf_convolution_init.c)
        endif()

        if(CONFIG_EBUR128_FILTER)
            list(APPEND avfilter_sources x86/f_ebur128.asm)
            list(APPEND avfilter_sources x86/f_ebur128_init.c)
        endif()

        if(CONFIG_EQ_FILTER)
            list(APPEND avfilter_sources x86/vf_eq.asm)
            list(APPEND avfilter_sources x86/vf_eq_init.c)
        endif()

        if(CONFIG_FRAMERATE_FILTER)
            list(APPEND avfilter_sources x86/vf_framerate.asm)
            list(APPEND avfilter_sources x86/vf_framerate_init.c)
        endif()

        if(CONFIG_FSPP_FILTER)
            list(APPEND avfilter_sources x86/vf_fspp.asm)
            list(APPEND avfilter_sources x86/vf_fspp_init.c)
        endif()

        if(CONFIG_GBLUR_FILTER)
            list(APPEND avfilter_sources x86/vf_gblur.asm)
            list(APPEND avfilter_sources x86/vf_gblur_init.c)
        endif()

        if(CONFIG_GRADFUN_FILTER)
            list(APPEND avfilter_sources x86/vf_gradfun.asm)
            list(APPEND avfilter_sources x86/vf_gradfun_init.c)
        endif()

        if(CONFIG_HALDCLUT_FILTER)
            list(APPEND avfilter_sources x86/vf_lut3d.asm)
            list(APPEND avfilter_sources x86/vf_lut3d_init.c)
        endif()

        if(CONFIG_HFLIP_FILTER)
            list(APPEND avfilter_sources x86/vf_hflip.asm)
            list(APPEND avfilter_sources x86/vf_hflip_init.c)
        endif()

        if(CONFIG_HQDN3D_FILTER)
            list(APPEND avfilter_sources x86/vf_hqdn3d.asm)
            list(APPEND avfilter_sources x86/vf_hqdn3d_init.c)
        endif()

        if(CONFIG_IDET_FILTER)
            list(APPEND avfilter_sources x86/vf_idetdsp.asm)
            list(APPEND avfilter_sources x86/vf_idetdsp_init.c)
        endif()

        if(CONFIG_INTERLACE_FILTER)
            list(APPEND avfilter_sources x86/vf_interlace.asm)
            list(APPEND avfilter_sources x86/vf_tinterlace_init.c)
        endif()

        if(CONFIG_LIMITER_FILTER)
            list(APPEND avfilter_sources x86/vf_limiter.asm)
            list(APPEND avfilter_sources x86/vf_limiter_init.c)
        endif()

        if(CONFIG_LUT3D_FILTER)
            list(APPEND avfilter_sources x86/vf_lut3d.asm)
            list(APPEND avfilter_sources x86/vf_lut3d_init.c)
        endif()

        if(CONFIG_MASKEDCLAMP_FILTER)
            list(APPEND avfilter_sources x86/vf_maskedclamp.asm)
            list(APPEND avfilter_sources x86/vf_maskedclamp_init.c)
        endif()

        if(CONFIG_MASKEDMERGE_FILTER)
            list(APPEND avfilter_sources x86/vf_maskedmerge.asm)
            list(APPEND avfilter_sources x86/vf_maskedmerge_init.c)
        endif()

        if(CONFIG_NLMEANS_FILTER)
            list(APPEND avfilter_sources x86/vf_nlmeans.asm)
            list(APPEND avfilter_sources x86/vf_nlmeans_init.c)
        endif()

        if(CONFIG_OVERLAY_FILTER)
            list(APPEND avfilter_sources x86/vf_overlay.asm)
            list(APPEND avfilter_sources x86/vf_overlay_init.c)
        endif()

        if(CONFIG_PP7_FILTER)
            list(APPEND avfilter_sources x86/vf_pp7.asm)
            list(APPEND avfilter_sources x86/vf_pp7_init.c)
        endif()

        if(CONFIG_PSNR_FILTER)
            list(APPEND avfilter_sources x86/vf_psnr.asm)
            list(APPEND avfilter_sources x86/vf_psnr_init.c)
        endif()

        if(CONFIG_PULLUP_FILTER)
            list(APPEND avfilter_sources x86/vf_pullup.asm)
            list(APPEND avfilter_sources x86/vf_pullup_init.c)
        endif()

        if(CONFIG_REMOVEGRAIN_FILTER)
            list(APPEND avfilter_sources x86/vf_removegrain.asm)
            list(APPEND avfilter_sources x86/vf_removegrain_init.c)
        endif()

        if(CONFIG_SHOWCQT_FILTER)
            list(APPEND avfilter_sources x86/avf_showcqt.asm)
            list(APPEND avfilter_sources x86/avf_showcqt_init.c)
        endif()

        if(CONFIG_SOBEL_FILTER)
            list(APPEND avfilter_sources x86/vf_convolution.asm)
            list(APPEND avfilter_sources x86/vf_convolution_init.c)
        endif()

        if(CONFIG_SSIM_FILTER)
            list(APPEND avfilter_sources x86/vf_ssim.asm)
            list(APPEND avfilter_sources x86/vf_ssim_init.c)
        endif()

        if(CONFIG_STEREO3D_FILTER)
            list(APPEND avfilter_sources x86/vf_stereo3d.asm)
            list(APPEND avfilter_sources x86/vf_stereo3d_init.c)
        endif()

        if(CONFIG_TBLEND_FILTER)
            list(APPEND avfilter_sources x86/vf_blend.asm)
            list(APPEND avfilter_sources x86/vf_blend_init.c)
        endif()

        if(CONFIG_THRESHOLD_FILTER)
            list(APPEND avfilter_sources x86/vf_threshold.asm)
            list(APPEND avfilter_sources x86/vf_threshold_init.c)
        endif()

        if(CONFIG_TINTERLACE_FILTER)
            list(APPEND avfilter_sources x86/vf_interlace.asm)
            list(APPEND avfilter_sources x86/vf_tinterlace_init.c)
        endif()

        if(CONFIG_TRANSPOSE_FILTER)
            list(APPEND avfilter_sources x86/vf_transpose.asm)
            list(APPEND avfilter_sources x86/vf_transpose_init.c)
        endif()

        if(CONFIG_VOLUME_FILTER)
            list(APPEND avfilter_sources x86/af_volume.asm)
            list(APPEND avfilter_sources x86/af_volume_init.c)
        endif()

        if(CONFIG_V360_FILTER)
            list(APPEND avfilter_sources x86/vf_v360.asm)
            list(APPEND avfilter_sources x86/vf_v360_init.c)
        endif()

        if(CONFIG_W3FDIF_FILTER)
            list(APPEND avfilter_sources x86/vf_w3fdif.asm)
            list(APPEND avfilter_sources x86/vf_w3fdif_init.c)
        endif()

        if(CONFIG_XPSNR_FILTER)
            list(APPEND avfilter_sources x86/vf_psnr.asm)
            list(APPEND avfilter_sources x86/vf_psnr_init.c)
        endif()

        if(CONFIG_YADIF_FILTER)
            list(APPEND avfilter_sources x86/vf_yadif.asm)
            list(APPEND avfilter_sources x86/yadif-16.asm)
            list(APPEND avfilter_sources x86/yadif-10.asm)
            list(APPEND avfilter_sources x86/vf_yadif_init.c)
        endif()

    endif()
endif()

# ============================================================================
# AArch64 architecture-specific sources
# ============================================================================
if(ARCH_AARCH64 AND ENABLE_ASM)

    # AArch64 C sources (conditional)
    if(CONFIG_BWDIF_FILTER)
        list(APPEND avfilter_sources aarch64/vf_bwdif_init_aarch64.c)
    endif()

    if(CONFIG_COLORDETECT_FILTER)
        list(APPEND avfilter_sources aarch64/vf_colordetect_init.c)
    endif()

    if(CONFIG_NLMEANS_FILTER)
        list(APPEND avfilter_sources aarch64/vf_nlmeans_init.c)
    endif()

    if(HAVE_NEON)
        # NEON sources (conditional)
        if(CONFIG_BWDIF_FILTER)
            list(APPEND avfilter_sources aarch64/vf_bwdif_neon.S)
        endif()

        if(CONFIG_COLORDETECT_FILTER)
            list(APPEND avfilter_sources aarch64/vf_colordetect_neon.S)
        endif()

        if(CONFIG_NLMEANS_FILTER)
            list(APPEND avfilter_sources aarch64/vf_nlmeans_neon.S)
        endif()

    endif()

endif()

# ============================================================================
# Thread support (from OBJS-$(HAVE_THREADS) in Makefile)
# ============================================================================
if(HAVE_THREADS)
    list(APPEND avfilter_sources pthread.c)
endif()

# ============================================================================
# Remove duplicates
# ============================================================================
list(REMOVE_DUPLICATES avfilter_sources)

# Filter out source files that don't exist
set(avfilter_sources_filtered "")
foreach(src IN LISTS avfilter_sources)
    if(IS_ABSOLUTE "${src}")
        list(APPEND avfilter_sources_filtered "${src}")
    elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
        list(APPEND avfilter_sources_filtered "${src}")
    else()
        message(STATUS "avfilter: skipping missing source file: ${src}")
    endif()
endforeach()
set(avfilter_sources ${avfilter_sources_filtered})

# ============================================================================
# Generate filter_list.c and allfilters.c
# Scan compiled source files for FFFilter symbol definitions
# ============================================================================

set(avfilter_filter_symbols "")

# Scan each source file for FFFilter definitions
foreach(src IN LISTS avfilter_sources)
    if(IS_ABSOLUTE "${src}")
        set(_src_abs "${src}")
    else()
        set(_src_abs "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
    endif()
    if(NOT EXISTS "${_src_abs}")
        continue()
    endif()
    file(STRINGS "${_src_abs}" _filter_lines REGEX "^const FFFilter ff_[a-zA-Z0-9_]+ =")
    foreach(_fline IN LISTS _filter_lines)
        string(REGEX MATCH "ff_[a-zA-Z0-9_]+" _fsym "${_fline}")
        if(_fsym)
            list(APPEND avfilter_filter_symbols "${_fsym}")
        endif()
    endforeach()
endforeach()

# Filters defined via macros (not detectable by simple file scan)
# af_biquads.c: ff_af_equalizer, ff_af_bass, ff_af_lowshelf, etc.
if(CONFIG_EQUALIZER_FILTER OR CONFIG_BASS_FILTER OR CONFIG_LOWSHELF_FILTER OR
   CONFIG_TREBLE_FILTER OR CONFIG_HIGHSHELF_FILTER OR CONFIG_TILTSHELF_FILTER OR
   CONFIG_BANDPASS_FILTER OR CONFIG_BANDREJECT_FILTER OR CONFIG_LOWPASS_FILTER OR
   CONFIG_HIGHPASS_FILTER OR CONFIG_ALLPASS_FILTER OR CONFIG_BIQUAD_FILTER)
    list(APPEND avfilter_filter_symbols
        ff_af_equalizer ff_af_bass ff_af_lowshelf ff_af_treble
        ff_af_highshelf ff_af_tiltshelf ff_af_bandpass ff_af_bandreject
        ff_af_lowpass ff_af_highpass ff_af_allpass ff_af_biquad
    )
endif()

# vf_neighbor.c: ff_vf_erosion, ff_vf_dilation, ff_vf_deflate, ff_vf_inflate
if(CONFIG_EROSION_FILTER OR CONFIG_DILATION_FILTER OR CONFIG_DEFLATE_FILTER OR CONFIG_INFLATE_FILTER)
    list(APPEND avfilter_filter_symbols
        ff_vf_erosion ff_vf_dilation ff_vf_deflate ff_vf_inflate
    )
endif()

# vf_lut.c: ff_vf_lut, ff_vf_lutyuv, ff_vf_lutrgb
if(CONFIG_LUT_FILTER OR CONFIG_LUTYUV_FILTER OR CONFIG_LUTRGB_FILTER)
    list(APPEND avfilter_filter_symbols
        ff_vf_lut ff_vf_lutyuv ff_vf_lutrgb
    )
endif()

# Special buffer/abuffer filters (always needed)
set(avfilter_buffer_symbols
    ff_asrc_abuffer
    ff_vsrc_buffer
    ff_asink_abuffer
    ff_vsink_buffer
)

list(REMOVE_DUPLICATES avfilter_filter_symbols)

# Remove filter symbols for disabled filters that share source files with enabled filters
# (e.g., ff_vf_libvmaf_cuda is defined in vf_libvmaf.c which is compiled for CONFIG_LIBVMAF_FILTER)
if(NOT CONFIG_LIBVMAF_CUDA_FILTER)
    list(REMOVE_ITEM avfilter_filter_symbols ff_vf_libvmaf_cuda)
endif()

# Generate filter_list.c
set(FILTER_LIST_CONTENT "static const FFFilter * const filter_list[] = {\n")
foreach(sym IN LISTS avfilter_filter_symbols)
    string(APPEND FILTER_LIST_CONTENT "    &${sym},\n")
endforeach()
foreach(sym IN LISTS avfilter_buffer_symbols)
    string(APPEND FILTER_LIST_CONTENT "    &${sym},\n")
endforeach()
string(APPEND FILTER_LIST_CONTENT "    NULL,\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavfilter/filter_list.c" "${FILTER_LIST_CONTENT}")

# Generate allfilters.c
set(ALLFILTERS_CONTENT
"/*
 * filter registration - auto-generated by CMake
 * Based on libavfilter/allfilters.c
 */

#include \"avfilter.h\"
#include \"filters.h\"

")

foreach(sym IN LISTS avfilter_filter_symbols)
    string(APPEND ALLFILTERS_CONTENT "extern const FFFilter ${sym};\n")
endforeach()

string(APPEND ALLFILTERS_CONTENT "\n/* buffer/abuffer filters */\n")
foreach(sym IN LISTS avfilter_buffer_symbols)
    string(APPEND ALLFILTERS_CONTENT "extern  const FFFilter ${sym};\n")
endforeach()

string(APPEND ALLFILTERS_CONTENT "
#include \"libavfilter/filter_list.c\"

const AVFilter *av_filter_iterate(void **opaque)
{
    uintptr_t i = (uintptr_t)*opaque;
    const FFFilter *f = filter_list[i];

    if (f) {
        *opaque = (void*)(i + 1);
        return &f->p;
    }

    return NULL;
}

const AVFilter *avfilter_get_by_name(const char *name)
{
    const AVFilter *f = NULL;
    void *opaque = 0;

    if (!name)
        return NULL;

    while ((f = av_filter_iterate(&opaque)))
        if (!strcmp(f->name, name))
            return f;

    return NULL;
}
")

file(WRITE "${CMAKE_BINARY_DIR}/libavfilter/allfilters.c" "${ALLFILTERS_CONTENT}")

# Use the generated allfilters.c instead of the source one
list(APPEND avfilter_sources "${CMAKE_BINARY_DIR}/libavfilter/allfilters.c")

# ============================================================================
# Create the library
# ============================================================================
add_library(avfilter STATIC ${avfilter_sources})

# Include directories
target_include_directories(avfilter
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/libavfilter>
)

# Add source directory as NASM include path for each .asm file
if(ARCH_X86 AND ENABLE_ASM AND HAVE_X86ASM)
    nasm_add_source_dir_includes(avfilter)
endif()

# Link dependencies
target_link_libraries(avfilter
    PRIVATE
        swscale
        avformat
        avcodec
        swresample
        avutil
        Threads::Threads
)

# Link FriBidi if available (needed for vf_drawtext bidirectional text)
if(CONFIG_LIBFRIBIDI AND LIBFRIBIDI_LIBRARIES)
    if(LIBFRIBIDI_LIBRARY_DIRS)
        target_link_directories(avfilter PUBLIC ${LIBFRIBIDI_LIBRARY_DIRS})
    endif()
    target_link_libraries(avfilter PRIVATE ${LIBFRIBIDI_LIBRARIES})
    if(LIBFRIBIDI_INCLUDE_DIRS)
        target_include_directories(avfilter PRIVATE ${LIBFRIBIDI_INCLUDE_DIRS})
    endif()
endif()

# Link FreeType2 if available (needed for vf_drawtext)
if(Freetype_FOUND OR FREETYPE_FOUND)
    if(Freetype_FOUND)
        target_link_libraries(avfilter PRIVATE Freetype::Freetype)
    elseif(TARGET PkgConfig::FREETYPE)
        target_link_libraries(avfilter PRIVATE PkgConfig::FREETYPE)
    else()
        target_link_libraries(avfilter PRIVATE ${FREETYPE_LIBRARIES})
        target_include_directories(avfilter PRIVATE ${FREETYPE_INCLUDE_DIRS})
        if(FREETYPE_LIBRARY_DIRS)
            target_link_directories(avfilter PRIVATE ${FREETYPE_LIBRARY_DIRS})
        endif()
    endif()
else()
    message(STATUS "avfilter: FreeType2 not found, excluding vf_drawtext.c")
    get_target_property(_avflt_srcs avfilter SOURCES)
    list(FILTER _avflt_srcs EXCLUDE REGEX "vf_drawtext\.c$")
    set_target_properties(avfilter PROPERTIES SOURCES "${_avflt_srcs}")

    set(_drawtext_stub "${CMAKE_CURRENT_BINARY_DIR}/vf_drawtext_stub.c")
    file(WRITE "${_drawtext_stub}" "
/* Auto-generated stub: ff_vf_drawtext when FreeType2 is not available */
#include \"avfilter.h\"
#include \"filters.h\"

const AVFilter ff_vf_drawtext = {
    .name        = \"drawtext\",
    .description = \"Draw text on the video frame (stub, FreeType2 not available)\",
};
")
    target_sources(avfilter PRIVATE "${_drawtext_stub}")
endif()

# Link HarfBuzz if available (needed for vf_drawtext text shaping)
if(HARFBUZZ_FOUND)
    if(TARGET PkgConfig::HARFBUZZ)
        target_link_libraries(avfilter PRIVATE PkgConfig::HARFBUZZ)
    else()
        target_link_libraries(avfilter PRIVATE ${HARFBUZZ_LIBRARIES})
        target_include_directories(avfilter PRIVATE ${HARFBUZZ_INCLUDE_DIRS})
        if(HARFBUZZ_LIBRARY_DIRS)
            target_link_directories(avfilter PRIVATE ${HARFBUZZ_LIBRARY_DIRS})
        endif()
    endif()
endif()

# Link Vulkan if available (needed for Vulkan filters)
if(Vulkan_FOUND)
    target_link_libraries(avfilter PRIVATE Vulkan::Vulkan)
    target_include_directories(avfilter PRIVATE ${Vulkan_INCLUDE_DIRS})
endif()

# Link Fontconfig if available (needed for avf_showcqt font lookup)
if(CONFIG_LIBFONTCONFIG AND LIBFONTCONFIG_LIBRARIES)
    target_link_libraries(avfilter PRIVATE ${LIBFONTCONFIG_LIBRARIES})
    if(LIBFONTCONFIG_INCLUDE_DIRS)
        target_include_directories(avfilter PRIVATE ${LIBFONTCONFIG_INCLUDE_DIRS})
    endif()
    if(LIBFONTCONFIG_LIBRARY_DIRS)
        target_link_directories(avfilter PRIVATE ${LIBFONTCONFIG_LIBRARY_DIRS})
    endif()
endif()

# Link VAAPI if available (needed for vaapi_vpp.c and VAAPI filters)
if(CONFIG_VAAPI AND VAAPI_LIBRARIES)
    target_link_libraries(avfilter PRIVATE ${VAAPI_LIBRARIES})
    if(VAAPI_INCLUDE_DIRS)
        target_include_directories(avfilter PRIVATE ${VAAPI_INCLUDE_DIRS})
    endif()
endif()

# Compiler definitions
target_compile_definitions(avfilter PRIVATE
    HAVE_AV_CONFIG_H
    BUILDING_avfilter
)

# Position independent code for shared builds
set_pic_if_needed(avfilter)

# Set output name
set_target_properties(avfilter PROPERTIES
    OUTPUT_NAME avfilter
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

list(LENGTH avfilter_filter_symbols _n_filters)
message(STATUS "libavfilter configured with ${_n_filters} filters")
