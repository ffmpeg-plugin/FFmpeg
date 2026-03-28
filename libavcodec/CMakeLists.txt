# libavcodec CMakeLists.txt
# Based on libavcodec/Makefile OBJS list

# ============================================================================
# Core sources (unconditional, from OBJS = in Makefile)
# ============================================================================
set(avcodec_sources
    ac3_parser.c
    adts_parser.c
    # allcodecs.c is replaced by generated allcodecs_generated.c (see below)
    avcodec.c
    avdct.c
    packet.c
    bitstream.c
    bitstream_filters.c
    bsf.c
    codec_desc.c
    codec_par.c
    d3d11va.c
    decode.c
    dirac.c
    dv_profile.c
    encode.c
    exif.c
    get_buffer.c
    imgconvert.c
    jni.c
    mathtables.c
    mediacodec.c
    mpeg12framerate.c
    options.c
    parser.c
    parsers.c
    profiles.c
    qsv_api.c
    raw.c
    threadprogress.c
    tiff_common.c
    utils.c
    version.c
    vlc.c
    vorbis_parser.c
    xiph.c
)

# ============================================================================
# Subsystem sources (from include $(SRC_PATH)/libavcodec/aac/Makefile etc.)
# ============================================================================

# Helper macro: auto-scan a subdirectory, skipping template files
macro(avcodec_scan_subdir _subdir)
    if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${_subdir}")
        file(GLOB _subdir_files "${CMAKE_CURRENT_SOURCE_DIR}/${_subdir}/*.c")
        foreach(_src_abs IN LISTS _subdir_files)
            get_filename_component(_src_name "${_src_abs}" NAME)
            if(NOT "${_src_name}" MATCHES "_template\.c$")
                list(APPEND avcodec_sources "${_subdir}/${_src_name}")
            endif()
        endforeach()
    endif()
endmacro()

# AAC subsystem
avcodec_scan_subdir(aac)

# HEVC subsystem
avcodec_scan_subdir(hevc)

# Opus subsystem
avcodec_scan_subdir(opus)

# VVC subsystem
avcodec_scan_subdir(vvc)

# H26x shared templates (template-only, no direct compilation needed)
# avcodec_scan_subdir(h26x)  # all files are _template.c, skip

# BSF subsystem
avcodec_scan_subdir(bsf)

# ============================================================================
# Conditional sources based on CONFIG_* variables
# ============================================================================

# Internal subsystems
# AANDCTTABLES
if(CONFIG_AANDCTTABLES)
    list(APPEND avcodec_sources aandcttab.c)
endif()


# AC3DSP
if(CONFIG_AC3DSP)
    list(APPEND avcodec_sources ac3dsp.c)
    list(APPEND avcodec_sources ac3.c)
    list(APPEND avcodec_sources ac3tab.c)
endif()


# ADTS_HEADER
if(CONFIG_ADTS_HEADER)
    list(APPEND avcodec_sources adts_header.c)
    list(APPEND avcodec_sources mpeg4audio_sample_rates.c)
endif()


# AUDIO_FRAME_QUEUE
if(CONFIG_AUDIO_FRAME_QUEUE)
    list(APPEND avcodec_sources audio_frame_queue.c)
endif()


# ATSC_A53
if(CONFIG_ATSC_A53)
    list(APPEND avcodec_sources atsc_a53.c)
endif()


# AUDIODSP
if(CONFIG_AUDIODSP)
    list(APPEND avcodec_sources audiodsp.c)
endif()


# BLOCKDSP
if(CONFIG_BLOCKDSP)
    list(APPEND avcodec_sources blockdsp.c)
endif()


# BSWAPDSP
if(CONFIG_BSWAPDSP)
    list(APPEND avcodec_sources bswapdsp.c)
endif()


# CABAC
if(CONFIG_CABAC)
    list(APPEND avcodec_sources cabac.c)
endif()


# CBS
if(CONFIG_CBS)
    list(APPEND avcodec_sources cbs.c)
    list(APPEND avcodec_sources cbs_bsf.c)
endif()


# CBS_APV
if(CONFIG_CBS_APV)
    list(APPEND avcodec_sources cbs_apv.c)
endif()


# CBS_AV1
if(CONFIG_CBS_AV1)
    list(APPEND avcodec_sources cbs_av1.c)
endif()


# CBS_H264
if(CONFIG_CBS_H264)
    list(APPEND avcodec_sources cbs_h264.c)
    list(APPEND avcodec_sources cbs_h2645.c)
    list(APPEND avcodec_sources cbs_sei.c)
    list(APPEND avcodec_sources h2645_parse.c)
endif()


# CBS_H265
if(CONFIG_CBS_H265)
    list(APPEND avcodec_sources cbs_h265.c)
    list(APPEND avcodec_sources cbs_h2645.c)
    list(APPEND avcodec_sources cbs_sei.c)
    list(APPEND avcodec_sources h2645_parse.c)
endif()


# CBS_H266
if(CONFIG_CBS_H266)
    list(APPEND avcodec_sources cbs_h266.c)
    list(APPEND avcodec_sources cbs_h2645.c)
    list(APPEND avcodec_sources cbs_sei.c)
    list(APPEND avcodec_sources h2645_parse.c)
endif()


# CBS_JPEG
if(CONFIG_CBS_JPEG)
    list(APPEND avcodec_sources cbs_jpeg.c)
endif()


# CBS_MPEG2
if(CONFIG_CBS_MPEG2)
    list(APPEND avcodec_sources cbs_mpeg2.c)
endif()


# CBS_VP8
if(CONFIG_CBS_VP8)
    list(APPEND avcodec_sources cbs_vp8.c)
    list(APPEND avcodec_sources vp8data.c)
endif()


# CBS_VP9
if(CONFIG_CBS_VP9)
    list(APPEND avcodec_sources cbs_vp9.c)
endif()


# CELP_MATH
if(CONFIG_CELP_MATH)
    list(APPEND avcodec_sources celp_math.c)
endif()


# DOVI_RPUDEC
if(CONFIG_DOVI_RPUDEC)
    list(APPEND avcodec_sources dovi_rpu.c)
    list(APPEND avcodec_sources dovi_rpudec.c)
endif()


# DOVI_RPUENC
if(CONFIG_DOVI_RPUENC)
    list(APPEND avcodec_sources dovi_rpu.c)
    list(APPEND avcodec_sources dovi_rpuenc.c)
endif()


# ERROR_RESILIENCE
if(CONFIG_ERROR_RESILIENCE)
    list(APPEND avcodec_sources error_resilience.c)
endif()


# FAANDCT
if(CONFIG_FAANDCT)
    list(APPEND avcodec_sources faandct.c)
endif()


# FAANIDCT
if(CONFIG_FAANIDCT)
    list(APPEND avcodec_sources faanidct.c)
endif()


# FDCTDSP
if(CONFIG_FDCTDSP)
    list(APPEND avcodec_sources fdctdsp.c)
    list(APPEND avcodec_sources jfdctfst.c)
    list(APPEND avcodec_sources jfdctint.c)
endif()


# FMTCONVERT
if(CONFIG_FMTCONVERT)
    list(APPEND avcodec_sources fmtconvert.c)
endif()


# GOLOMB
if(CONFIG_GOLOMB)
    list(APPEND avcodec_sources golomb.c)
endif()


# H263DSP
if(CONFIG_H263DSP)
    list(APPEND avcodec_sources h263dsp.c)
endif()


# H264CHROMA
if(CONFIG_H264CHROMA)
    list(APPEND avcodec_sources h264chroma.c)
endif()


# H264DSP
if(CONFIG_H264DSP)
    list(APPEND avcodec_sources h264dsp.c)
    list(APPEND avcodec_sources h264idct.c)
endif()


# H264PARSE
if(CONFIG_H264PARSE)
    list(APPEND avcodec_sources h264_parse.c)
    list(APPEND avcodec_sources h264_ps.c)
    list(APPEND avcodec_sources h264data.c)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources h2645_parse.c)
    list(APPEND avcodec_sources h2645_vui.c)
endif()


# H264PRED
if(CONFIG_H264PRED)
    list(APPEND avcodec_sources h264pred.c)
endif()


# H264QPEL
if(CONFIG_H264QPEL)
    list(APPEND avcodec_sources h264qpel.c)
endif()


# H264_SEI
if(CONFIG_H264_SEI)
    list(APPEND avcodec_sources h264_sei.c)
    list(APPEND avcodec_sources h2645_sei.c)
    list(APPEND avcodec_sources aom_film_grain.c)
endif()


# HEVCPARSE
if(CONFIG_HEVCPARSE)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources h2645_parse.c)
    list(APPEND avcodec_sources h2645_vui.c)
endif()


# HEVC_SEI
if(CONFIG_HEVC_SEI)
    list(APPEND avcodec_sources h2645_sei.c)
    list(APPEND avcodec_sources aom_film_grain.c)
    list(APPEND avcodec_sources dynamic_hdr_vivid.c)
endif()


# HPELDSP
if(CONFIG_HPELDSP)
    list(APPEND avcodec_sources hpeldsp.c)
endif()


# HUFFMAN
if(CONFIG_HUFFMAN)
    list(APPEND avcodec_sources huffman.c)
endif()


# HUFFYUVDSP
if(CONFIG_HUFFYUVDSP)
    list(APPEND avcodec_sources huffyuvdsp.c)
endif()


# HUFFYUVENCDSP
if(CONFIG_HUFFYUVENCDSP)
    list(APPEND avcodec_sources huffyuvencdsp.c)
endif()


# IDCTDSP
if(CONFIG_IDCTDSP)
    list(APPEND avcodec_sources idctdsp.c)
    list(APPEND avcodec_sources simple_idct.c)
    list(APPEND avcodec_sources jrevdct.c)
endif()


# INTRAX8
if(CONFIG_INTRAX8)
    list(APPEND avcodec_sources intrax8.c)
    list(APPEND avcodec_sources intrax8dsp.c)
    list(APPEND avcodec_sources msmpeg4_vc1_data.c)
endif()


# IVIDSP
if(CONFIG_IVIDSP)
    list(APPEND avcodec_sources ivi_dsp.c)
endif()


# JPEGTABLES
if(CONFIG_JPEGTABLES)
    list(APPEND avcodec_sources jpegtables.c)
endif()


# LLAUDDSP
if(CONFIG_LLAUDDSP)
    list(APPEND avcodec_sources lossless_audiodsp.c)
endif()


# LLVIDDSP
if(CONFIG_LLVIDDSP)
    list(APPEND avcodec_sources lossless_videodsp.c)
endif()


# LLVIDENCDSP
if(CONFIG_LLVIDENCDSP)
    list(APPEND avcodec_sources lossless_videoencdsp.c)
endif()


# LPC
if(CONFIG_LPC)
    list(APPEND avcodec_sources lpc.c)
endif()


# LSP
if(CONFIG_LSP)
    list(APPEND avcodec_sources lsp.c)
endif()


# LZF
if(CONFIG_LZF)
    list(APPEND avcodec_sources lzf.c)
endif()


# ME_CMP
if(CONFIG_ME_CMP)
    list(APPEND avcodec_sources me_cmp.c)
endif()


# MPEG_ER
if(CONFIG_MPEG_ER)
    list(APPEND avcodec_sources mpeg_er.c)
endif()


# MPEGAUDIO
if(CONFIG_MPEGAUDIO)
    list(APPEND avcodec_sources mpegaudio.c)
    list(APPEND avcodec_sources mpegaudiodec_common.c)
    list(APPEND avcodec_sources mpegaudiodata.c)
endif()


# MPEGAUDIODSP
if(CONFIG_MPEGAUDIODSP)
    list(APPEND avcodec_sources mpegaudiodsp.c)
    list(APPEND avcodec_sources mpegaudiodsp_data.c)
    list(APPEND avcodec_sources mpegaudiodsp_fixed.c)
    list(APPEND avcodec_sources mpegaudiodsp_float.c)
    list(APPEND avcodec_sources dct32_fixed.c)
    list(APPEND avcodec_sources dct32_float.c)
endif()


# MPEGAUDIOHEADER
if(CONFIG_MPEGAUDIOHEADER)
    list(APPEND avcodec_sources mpegaudiodecheader.c)
    list(APPEND avcodec_sources mpegaudiotabs.c)
endif()


# MPEG4AUDIO
if(CONFIG_MPEG4AUDIO)
    list(APPEND avcodec_sources mpeg4audio.c)
    list(APPEND avcodec_sources mpeg4audio_sample_rates.c)
endif()


# MPEGVIDEO
if(CONFIG_MPEGVIDEO)
    list(APPEND avcodec_sources mpegvideo.c)
    list(APPEND avcodec_sources rl.c)
    list(APPEND avcodec_sources mpegvideo_motion.c)
    list(APPEND avcodec_sources mpegvideo_unquantize.c)
    list(APPEND avcodec_sources mpegvideodata.c)
    list(APPEND avcodec_sources mpegpicture.c)
    list(APPEND avcodec_sources to_upper4.c)
endif()


# MPEGVIDEODEC
if(CONFIG_MPEGVIDEODEC)
    list(APPEND avcodec_sources mpegvideo_dec.c)
    list(APPEND avcodec_sources mpegutils.c)
endif()


# MPEGVIDEOENC
if(CONFIG_MPEGVIDEOENC)
    list(APPEND avcodec_sources mpegvideo_enc.c)
    list(APPEND avcodec_sources mpeg12data.c)
    list(APPEND avcodec_sources motion_est.c)
    list(APPEND avcodec_sources ratecontrol.c)
endif()


# MPEGVIDEOENCDSP
if(CONFIG_MPEGVIDEOENCDSP)
    list(APPEND avcodec_sources mpegvideoencdsp.c)
endif()


# MSMPEG4DEC
if(CONFIG_MSMPEG4DEC)
    list(APPEND avcodec_sources msmpeg4dec.c)
    list(APPEND avcodec_sources msmpeg4.c)
    list(APPEND avcodec_sources msmpeg4data.c)
    list(APPEND avcodec_sources msmpeg4_vc1_data.c)
    list(APPEND avcodec_sources mpeg4videodec.c)
endif()


# MSMPEG4ENC
if(CONFIG_MSMPEG4ENC)
    list(APPEND avcodec_sources msmpeg4enc.c)
    list(APPEND avcodec_sources msmpeg4.c)
    list(APPEND avcodec_sources msmpeg4data.c)
    list(APPEND avcodec_sources msmpeg4_vc1_data.c)
endif()


# MSS34DSP
if(CONFIG_MSS34DSP)
    list(APPEND avcodec_sources mss34dsp.c)
    list(APPEND avcodec_sources jpegquanttables.c)
endif()


# PIXBLOCKDSP
if(CONFIG_PIXBLOCKDSP)
    list(APPEND avcodec_sources pixblockdsp.c)
endif()


# QPELDSP
if(CONFIG_QPELDSP)
    list(APPEND avcodec_sources qpeldsp.c)
endif()


# RANGECODER
if(CONFIG_RANGECODER)
    list(APPEND avcodec_sources rangecoder.c)
endif()


# RV34DSP
if(CONFIG_RV34DSP)
    list(APPEND avcodec_sources rv34dsp.c)
endif()


# SINEWIN
if(CONFIG_SINEWIN)
    list(APPEND avcodec_sources sinewin.c)
endif()


# SMPTE_436M
if(CONFIG_SMPTE_436M)
    list(APPEND avcodec_sources smpte_436m.c)
endif()


# STARTCODE
if(CONFIG_STARTCODE)
    list(APPEND avcodec_sources startcode.c)
endif()


# TEXTUREDSP
if(CONFIG_TEXTUREDSP)
    list(APPEND avcodec_sources texturedsp.c)
endif()


# TEXTUREDSPENC
if(CONFIG_TEXTUREDSPENC)
    list(APPEND avcodec_sources texturedspenc.c)
endif()


# TPELDSP
if(CONFIG_TPELDSP)
    list(APPEND avcodec_sources tpeldsp.c)
endif()


# VC1DSP
if(CONFIG_VC1DSP)
    list(APPEND avcodec_sources vc1dsp.c)
endif()


# VIDEODSP
if(CONFIG_VIDEODSP)
    list(APPEND avcodec_sources videodsp.c)
endif()


# VP3DSP
if(CONFIG_VP3DSP)
    list(APPEND avcodec_sources vp3dsp.c)
endif()


# VP8DSP
if(CONFIG_VP8DSP)
    list(APPEND avcodec_sources vp8dsp.c)
endif()


# WMA_FREQS
if(CONFIG_WMA_FREQS)
    list(APPEND avcodec_sources wma_freqs.c)
endif()


# WMV2DSP
if(CONFIG_WMV2DSP)
    list(APPEND avcodec_sources wmv2dsp.c)
endif()


# DIRAC_PARSE
if(CONFIG_DIRAC_PARSE)
    list(APPEND avcodec_sources dirac_parser.c)
endif()


# DVPROFILE
if(CONFIG_DVPROFILE)
    list(APPEND avcodec_sources dv_profile.c)
endif()


# IAMF is in libavformat, not libavcodec

# ============================================================================
# Decoder sources (CONFIG_*_DECODER)
# ============================================================================

# H.264 decoder
# H264_DECODER
if(CONFIG_H264_DECODER)
    list(APPEND avcodec_sources h264dec.c)
    list(APPEND avcodec_sources h264_cabac.c)
    list(APPEND avcodec_sources h264_cavlc.c)
    list(APPEND avcodec_sources h264_direct.c)
    list(APPEND avcodec_sources h264_loopfilter.c)
    list(APPEND avcodec_sources h264_mb.c)
    list(APPEND avcodec_sources h264_picture.c)
    list(APPEND avcodec_sources h264_refs.c)
    list(APPEND avcodec_sources h264_sei.c)
    list(APPEND avcodec_sources h264_slice.c)
endif()


# HEVC decoder

# MPEG-4 decoder
# MPEG4_DECODER
if(CONFIG_MPEG4_DECODER)
    list(APPEND avcodec_sources mpeg4videodec.c)
    list(APPEND avcodec_sources mpeg4video.c)
    list(APPEND avcodec_sources mpeg4videodsp.c)
endif()


# MPEG-4 encoder
# MPEG4_ENCODER
if(CONFIG_MPEG4_ENCODER)
    list(APPEND avcodec_sources mpeg4videoenc.c)
    list(APPEND avcodec_sources mpeg4video.c)
endif()


# MPEG-1/2 decoder
# (multi-condition block - unconditional)
    list(APPEND avcodec_sources mpeg12.c)
    list(APPEND avcodec_sources mpeg12dec.c)
    list(APPEND avcodec_sources mpeg12data.c)


# MPEG-1/2 encoder
# (multi-condition block - unconditional)
    list(APPEND avcodec_sources mpeg12enc.c)
    list(APPEND avcodec_sources mpeg12data.c)


# VP8 decoder
# VP8_DECODER
if(CONFIG_VP8_DECODER)
    list(APPEND avcodec_sources vp8.c)
    list(APPEND avcodec_sources vp8data.c)
endif()


# VP9 decoder
# VP9_DECODER
if(CONFIG_VP9_DECODER)
    list(APPEND avcodec_sources vp9.c)
    list(APPEND avcodec_sources vp9data.c)
    list(APPEND avcodec_sources vp9dsp.c)
    list(APPEND avcodec_sources vp9dsp_10bpp.c)
    list(APPEND avcodec_sources vp9dsp_12bpp.c)
    list(APPEND avcodec_sources vp9dsp_8bpp.c)
    list(APPEND avcodec_sources vp9lpf.c)
    list(APPEND avcodec_sources vp9mvs.c)
    list(APPEND avcodec_sources vp9prob.c)
    list(APPEND avcodec_sources vp9recon.c)
endif()


# AAC decoder
# AAC_DECODER
if(CONFIG_AAC_DECODER)
    list(APPEND avcodec_sources aactab.c)
    list(APPEND avcodec_sources aacsbr.c)
    list(APPEND avcodec_sources aacps_common.c)
    list(APPEND avcodec_sources aacps_float.c)
    list(APPEND avcodec_sources kbdwin.c)
    list(APPEND avcodec_sources sbrdsp.c)
    list(APPEND avcodec_sources aacpsdsp_float.c)
    list(APPEND avcodec_sources cbrt_data.c)
endif()


# AAC encoder
# AAC_ENCODER
if(CONFIG_AAC_ENCODER)
    list(APPEND avcodec_sources aacenc.c)
    list(APPEND avcodec_sources aacenc_is.c)
    list(APPEND avcodec_sources aacenc_pred.c)
    list(APPEND avcodec_sources aacenc_quantization.c)
    list(APPEND avcodec_sources aacenc_tns.c)
    list(APPEND avcodec_sources aacenctab.c)
    list(APPEND avcodec_sources aactab.c)
    list(APPEND avcodec_sources kbdwin.c)
    list(APPEND avcodec_sources psymodel.c)
    list(APPEND avcodec_sources iirfilter.c)
endif()


# MP3 decoder
# (multi-condition block - unconditional)
    list(APPEND avcodec_sources mpegaudiodec_fixed.c)
    list(APPEND avcodec_sources mpegaudiodec_float.c)


# AC3 decoder
# (multi-condition block - unconditional)
    list(APPEND avcodec_sources ac3dec_float.c)
    list(APPEND avcodec_sources ac3dec_fixed.c)


# AC3 encoder
# (multi-condition block - unconditional)
    list(APPEND avcodec_sources ac3enc.c)
    list(APPEND avcodec_sources ac3enc_float.c)
    list(APPEND avcodec_sources ac3enc_fixed.c)


# FLAC decoder
# FLAC_DECODER
if(CONFIG_FLAC_DECODER)
    list(APPEND avcodec_sources flacdec.c)
    list(APPEND avcodec_sources flac.c)
    list(APPEND avcodec_sources flacdata.c)
endif()


# FLAC encoder
# FLAC_ENCODER
if(CONFIG_FLAC_ENCODER)
    list(APPEND avcodec_sources flacenc.c)
    list(APPEND avcodec_sources flac.c)
    list(APPEND avcodec_sources flacdata.c)
endif()


# JPEG/MJPEG decoder
# (multi-condition block - unconditional)
    list(APPEND avcodec_sources mjpegdec.c)
    list(APPEND avcodec_sources mjpeg.c)


# JPEG/MJPEG encoder
# MJPEG_ENCODER
if(CONFIG_MJPEG_ENCODER)
    list(APPEND avcodec_sources mjpegenc.c)
    list(APPEND avcodec_sources mjpeg.c)
    list(APPEND avcodec_sources mjpegenc_common.c)
    list(APPEND avcodec_sources mjpegenc_huffman.c)
endif()


# PNG decoder
# PNG_DECODER
if(CONFIG_PNG_DECODER)
    list(APPEND avcodec_sources pngdec.c)
    list(APPEND avcodec_sources png.c)
    list(APPEND avcodec_sources pngdsp.c)
endif()


# PNG encoder
# PNG_ENCODER
if(CONFIG_PNG_ENCODER)
    list(APPEND avcodec_sources pngenc.c)
    list(APPEND avcodec_sources png.c)
endif()


# Vorbis decoder
# VORBIS_DECODER
if(CONFIG_VORBIS_DECODER)
    list(APPEND avcodec_sources vorbisdec.c)
    list(APPEND avcodec_sources vorbis.c)
    list(APPEND avcodec_sources vorbis_data.c)
endif()


# Vorbis encoder
# VORBIS_ENCODER
if(CONFIG_VORBIS_ENCODER)
    list(APPEND avcodec_sources vorbisenc.c)
    list(APPEND avcodec_sources vorbis.c)
    list(APPEND avcodec_sources vorbis_data.c)
endif()


# Opus decoder

# Opus encoder

# PCM codecs
# (multi-condition block - unconditional)
    list(APPEND avcodec_sources pcm.c)


# ADPCM codecs
# (multi-condition block - unconditional)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)


# DCA (DTS) decoder
# DCA_DECODER
if(CONFIG_DCA_DECODER)
    list(APPEND avcodec_sources dcadec.c)
    list(APPEND avcodec_sources dca.c)
    list(APPEND avcodec_sources dca_core.c)
    list(APPEND avcodec_sources dca_exss.c)
    list(APPEND avcodec_sources dca_lbr.c)
    list(APPEND avcodec_sources dca_xll.c)
    list(APPEND avcodec_sources dcadata.c)
    list(APPEND avcodec_sources dcadsp.c)
    list(APPEND avcodec_sources dcahuff.c)
    list(APPEND avcodec_sources dca_sample_rate_tab.c)
endif()


# WMV/WMA codecs
# (multi-condition block - unconditional)
    list(APPEND avcodec_sources wmv2dec.c)
    list(APPEND avcodec_sources wmv2.c)
    list(APPEND avcodec_sources wmv2dsp.c)


# (multi-condition block - unconditional)
    list(APPEND avcodec_sources wmadec.c)
    list(APPEND avcodec_sources wma.c)
    list(APPEND avcodec_sources wma_common.c)


# AV1 decoder
# AV1_DECODER
if(CONFIG_AV1_DECODER)
    list(APPEND avcodec_sources av1dec.c)
    list(APPEND avcodec_sources av1_parse.c)
endif()


# ============================================================================
# x86 architecture-specific sources
# ============================================================================
if(ARCH_X86 AND ENABLE_ASM)
    # Auto-scan all .c files in x86/ subdirectory
    file(GLOB _x86_c_files "${CMAKE_CURRENT_SOURCE_DIR}/x86/*.c")
    foreach(_src_abs IN LISTS _x86_c_files)
        get_filename_component(_src_name "${_src_abs}" NAME)
        # Skip test files
        if("${_src_name}" MATCHES "^w64xmmtest")
            continue()
        endif()
        # Skip template files
        if("${_src_name}" MATCHES "_template\\.c$")
            continue()
        endif()
        list(APPEND avcodec_sources "x86/${_src_name}")
    endforeach()

    if(HAVE_X86ASM)
        # Auto-scan all .asm files in x86/ subdirectory
        file(GLOB _x86_asm_files "${CMAKE_CURRENT_SOURCE_DIR}/x86/*.asm")
        foreach(_src_abs IN LISTS _x86_asm_files)
            get_filename_component(_src_name "${_src_abs}" NAME)
            list(APPEND avcodec_sources "x86/${_src_name}")
        endforeach()
    endif()

    # Auto-scan x86 sub-subdirectories (hevc, vvc, h26x)
    foreach(_x86_subdir hevc vvc h26x)
        if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/x86/${_x86_subdir}")
            file(GLOB _x86_sub_c "${CMAKE_CURRENT_SOURCE_DIR}/x86/${_x86_subdir}/*.c")
            foreach(_src_abs IN LISTS _x86_sub_c)
                get_filename_component(_src_name "${_src_abs}" NAME)
                if(NOT "${_src_name}" MATCHES "_template\\.c$")
                    list(APPEND avcodec_sources "x86/${_x86_subdir}/${_src_name}")
                endif()
            endforeach()
            if(HAVE_X86ASM)
                file(GLOB _x86_sub_asm "${CMAKE_CURRENT_SOURCE_DIR}/x86/${_x86_subdir}/*.asm")
                foreach(_src_abs IN LISTS _x86_sub_asm)
                    get_filename_component(_src_name "${_src_abs}" NAME)
                    list(APPEND avcodec_sources "x86/${_x86_subdir}/${_src_name}")
                endforeach()
            endif()
        endif()
    endforeach()
endif()

# ============================================================================
# AArch64 architecture-specific sources
# ============================================================================
if(ARCH_AARCH64 AND ENABLE_ASM)
    # Auto-scan all .c files in aarch64/ subdirectory
    file(GLOB _aarch64_c_files "${CMAKE_CURRENT_SOURCE_DIR}/aarch64/*.c")
    foreach(_src_abs IN LISTS _aarch64_c_files)
        get_filename_component(_src_name "${_src_abs}" NAME)
        if("${_src_name}" MATCHES "_template\\.c$")
            continue()
        endif()
        # rv40dsp_init_aarch64.c requires CONFIG_RV40_DECODER and matching NEON .S code
        if("${_src_name}" STREQUAL "rv40dsp_init_aarch64.c" AND NOT CONFIG_RV40_DECODER)
            continue()
        endif()
        list(APPEND avcodec_sources "aarch64/${_src_name}")
    endforeach()
    if(HAVE_NEON)
        file(GLOB _aarch64_asm_files "${CMAKE_CURRENT_SOURCE_DIR}/aarch64/*.S")
        foreach(_src_abs IN LISTS _aarch64_asm_files)
            get_filename_component(_src_name "${_src_abs}" NAME)
            # Skip neon.S - it's a header file included by other .S files
            if("${_src_name}" STREQUAL "neon.S")
                continue()
            endif()
            list(APPEND avcodec_sources "aarch64/${_src_name}")
        endforeach()
        # Also scan aarch64/h26x/ subdirectory (HEVC/H.264 shared NEON code)
        file(GLOB _aarch64_h26x_asm "${CMAKE_CURRENT_SOURCE_DIR}/aarch64/h26x/*.S")
        foreach(_src_abs IN LISTS _aarch64_h26x_asm)
            get_filename_component(_src_name "${_src_abs}" NAME)
            list(APPEND avcodec_sources "aarch64/h26x/${_src_name}")
        endforeach()
        # Scan neon/ subdirectory (NEON C helper files, e.g. mpegvideo.c)
        file(GLOB _neon_c_files "${CMAKE_CURRENT_SOURCE_DIR}/neon/*.c")
        foreach(_src_abs IN LISTS _neon_c_files)
            get_filename_component(_src_name "${_src_abs}" NAME)
            list(APPEND avcodec_sources "neon/${_src_name}")
        endforeach()
        # Scan aarch64/vvc/ subdirectory (VVC NEON code)
        file(GLOB _aarch64_vvc_c "${CMAKE_CURRENT_SOURCE_DIR}/aarch64/vvc/*.c")
        foreach(_src_abs IN LISTS _aarch64_vvc_c)
            get_filename_component(_src_name "${_src_abs}" NAME)
            # Skip template files - they are #included by other .c files
            if("${_src_name}" MATCHES "_template\\.c$")
                continue()
            endif()
            list(APPEND avcodec_sources "aarch64/vvc/${_src_name}")
        endforeach()
        file(GLOB _aarch64_vvc_asm "${CMAKE_CURRENT_SOURCE_DIR}/aarch64/vvc/*.S")
        foreach(_src_abs IN LISTS _aarch64_vvc_asm)
            get_filename_component(_src_name "${_src_abs}" NAME)
            list(APPEND avcodec_sources "aarch64/vvc/${_src_name}")
        endforeach()
    endif()
endif()

# ============================================================================
# Auto-scan: add all remaining .c files in libavcodec/ that are not
# already included, not template files, and not requiring external libs.
# This ensures codecs not explicitly listed above are still compiled.
# ============================================================================

# Files that are #included as templates by other .c files - do NOT compile directly
set(avcodec_template_files
    aacps.c
    aacps_tablegen_template.c
    aacpsdata.c
    aacpsdsp_template.c
    aacsbr_template.c
    ac3dec.c
    ac3enc_template.c
    aom_film_grain_template.c
    bit_depth_template.c
    bsf_list.c
    cbrt_tablegen_template.c
    cbs_apv_syntax_template.c
    cbs_av1_syntax_template.c
    cbs_h264_syntax_template.c
    cbs_h265_syntax_template.c
    cbs_h266_syntax_template.c
    cbs_jpeg_syntax_template.c
    cbs_lcevc_syntax_template.c
    cbs_mpeg2_syntax_template.c
    cbs_sei_syntax_template.c
    cbs_vp8_syntax_template.c
    cbs_vp9_syntax_template.c
    dct32_template.c
    fft_template.c
    golomb_tab.c
    h264pred_template.c
    hpeldsp_template.c
    huffyuv_template.c
    mdct_template.c
    mpeg4audio_sample_rates.c
    mpegaudio_tablegen_template.c
    mpegvideo_template.c
    opus_celt_template.c
    opus_pvq_template.c
    opus_silk_template.c
    pixblockdsp_template.c
    prores_template.c
    rdft_template.c
    rv34_template.c
    rv40_template.c
    simple_idct_template.c
    snow_dwt_template.c
    vp56_arith_template.c
    vp8_template.c
    vp9_template.c
    wmv2_template.c
    xvmc.c
)

# Files requiring external libraries not available by default
set(avcodec_external_lib_files
    # AMF (AMD Advanced Media Framework) - Windows only
    amfdec.c amfenc.c amfenc_av1.c amfenc_h264.c amfenc_hevc.c
    # AudioToolbox (macOS only)
    audiotoolboxdec.c audiotoolboxenc.c
    # VideoToolbox (macOS only)
    videotoolbox.c videotoolboxenc.c
    # MediaCodec (Android only)
    mediacodec_dec.c mediacodec_enc.c mediacodec_wrapper.c
    mediacodec_surface.c mediacodecdec.c mediacodecenc.c
    ffjni.c jni.c
    aac_mediacodec_dec.c h264_mediacodec_dec.c hevc_mediacodec_dec.c
    mpeg2_mediacodec_dec.c mpeg4_mediacodec_dec.c vp8_mediacodec_dec.c
    vp9_mediacodec_dec.c av1_mediacodec_dec.c
    # MF (Windows Media Foundation)
    mf_utils.c mfenc.c mfdec.c
    aac_mf_enc.c ac3_mf_enc.c h263_mf_enc.c h264_mf_enc.c
    hevc_mf_enc.c mp3_mf_enc.c mpeg4_mf_enc.c
    # NVENC/NVDEC (NVIDIA CUDA) - require ffnvcodec headers
    nvenc.c nvenc_av1.c nvenc_h264.c nvenc_hevc.c
    nvdec.c nvdec_av1.c nvdec_h264.c nvdec_hevc.c nvdec_mjpeg.c
    nvdec_mpeg12.c nvdec_mpeg4.c nvdec_vc1.c nvdec_vp8.c nvdec_vp9.c
    cuviddec.c h264_cuvid.c hevc_cuvid.c mjpeg_cuvid.c
    mpeg1_cuvid.c mpeg2_cuvid.c mpeg4_cuvid.c vp8_cuvid.c
    vp9_cuvid.c vc1_cuvid.c av1_cuvid.c
    # QSV (Intel Quick Sync Video)
    qsvdec.c qsvenc.c qsvenc_av1.c qsvenc_h264.c qsvenc_hevc.c
    qsvenc_jpeg.c qsvenc_mpeg2.c qsvenc_vp9.c
    h264_qsv.c hevc_qsv.c mjpeg_qsv.c mpeg2_qsv.c
    vp8_qsv.c vp9_qsv.c av1_qsv.c vc1_qsv.c
    # libx264/libx265
    libx264.c libx265.c
    # libvpx
    libvpxdec.c libvpxenc.c
    # libopus
    libopusdec.c libopusenc.c
    # libmp3lame
    libmp3lame.c
    # libfdk-aac
    libfdk-aacdec.c libfdk-aacenc.c
    # libaom
    libaomenc.c libaomenc_av1.c
    # libsvtav1
    libsvtav1.c
    # libdav1d
    libdav1d.c
    # libvorbis
    libvorbis.c libvorbisdec.c libvorbisenc.c
    # libtheora
    libtheora.c
    # libwebp
    libwebpenc.c libwebpenc_animencoder.c
    # libopenh264
    libopenh264dec.c libopenh264enc.c
    # libgsm
    libgsm.c libgsmdec.c libgsmenc.c
    # libspeex
    libspeexdec.c libspeexenc.c
    # libopenjpeg
    libopenjpegdec.c libopenjpegenc.c
    # libcodec2
    libcodec2.c
    # libjxl
    libjxldec.c libjxlenc.c
    # librav1e
    librav1e.c
    # libvpl (Intel VPL)
    vpl_dec.c vpl_enc.c
    # D3D11VA/D3D12VA (Windows only)
    d3d11va.c d3d12va_decode.c
    h264_d3d11va.c hevc_d3d11va.c mpeg2_d3d11va.c vc1_d3d11va.c
    vp9_d3d11va.c av1_d3d11va.c
    h264_d3d12va.c hevc_d3d12va.c av1_d3d12va.c vp9_d3d12va.c
    # DXVA2 (Windows only)
    dxva2.c
    h264_dxva2.c hevc_dxva2.c mpeg2_dxva2.c vc1_dxva2.c
    vp9_dxva2.c av1_dxva2.c
    # OpenCL
    av1_opencl.c
    # VAAPI
    vaapi_decode.c vaapi_encode.c
    vaapi_encode_av1.c vaapi_encode_h264.c vaapi_encode_h265.c
    vaapi_encode_mjpeg.c vaapi_encode_mpeg2.c vaapi_encode_vp8.c vaapi_encode_vp9.c
    h264_vaapi.c hevc_vaapi.c mjpeg_vaapi.c mpeg2_vaapi.c
    vp8_vaapi.c vp9_vaapi.c av1_vaapi.c vc1_vaapi.c
    av1_vaapi_enc.c h264_vaapi_enc.c hevc_vaapi_enc.c
    mjpeg_vaapi_enc.c mpeg2_vaapi_enc.c vp8_vaapi_enc.c vp9_vaapi_enc.c
    # VDPAU
    vdpau.c vdpau_mpeg12.c vdpau_mpeg4.c vdpau_h264.c
    vdpau_hevc.c vdpau_vc1.c vdpau_vp9.c
    # OpenAL/OpenGL/SDL
    openal_dec.c opengl_enc.c sdl2.c
    # libdc1394
    libdc1394.c
    # libavs3/libxavs/libkvazaar/libvvenc/libvvdec
    libavs3.c libxavs.c libxavs2.c libkvazaar.c libvvenc.c libvvdec.c
    # libuavs3d/libxeve/libxevd
    libuavs3d.c libxeve.c libxevd.c
    # libshine/libtwolame/libvo-amrwbenc/libvo-aacenc
    libshine.c libtwolame.c libvo_amrwbenc.c libvo_aacenc.c
    # libopencore-amr/libwavpack/libcelt
    libopencore_amrnb.c libopencore_amrwb.c libwavpack.c libcelt_dec.c
    # lcms2 (color management)
    fflcms2.c
    # snappy (compression library)
    hapenc.c
    # LCEVC (Low Complexity Enhancement Video Coding)
    lcevcdec.c
    # MMAL (Raspberry Pi hardware acceleration)
    mmaldec.c
    # OpenMAX (OMX)
    omx.c
    # VAAPI VVC (requires newer libva with va_dec_vvc.h)
    vaapi_vvc.c
)

# Tablegen files (generate lookup tables, not compiled into library)
# Exception: cbrt_tablegen_common.c defines ff_cbrt_dbl_tableinit used at
# runtime by cbrt_data.c - it must be compiled into the library.
# cbrt_tablegen.c and cbrt_fixed_tablegen.c are host tools that generate
# hardcoded tables; they include tableprint.h and must NOT be compiled in.
set(avcodec_tablegen_files "")
file(GLOB _tablegen_files "${CMAKE_CURRENT_SOURCE_DIR}/*tablegen*.c")
foreach(_f IN LISTS _tablegen_files)
    get_filename_component(_fname "${_f}" NAME)
    if(NOT "${_fname}" STREQUAL "cbrt_tablegen_common.c")
        list(APPEND avcodec_tablegen_files "${_fname}")
    endif()
endforeach()

# Combine all excluded files
# allcodecs.c is excluded because it references ALL codecs (including hardware-accelerated ones
# that are not compiled). It is replaced by the generated allcodecs_generated.c below.
set(avcodec_auto_excluded ${avcodec_template_files} ${avcodec_external_lib_files} ${avcodec_tablegen_files}
    allcodecs.c)

# Scan all .c files in libavcodec/ (top-level only, not subdirectories)
file(GLOB _all_avcodec_c "${CMAKE_CURRENT_SOURCE_DIR}/*.c")
set(avcodec_glob_excluded "")  # Track files excluded by GLOB conditions
foreach(_src_abs IN LISTS _all_avcodec_c)
    get_filename_component(_src_name "${_src_abs}" NAME)
    # Skip if in excluded list
    if("${_src_name}" IN_LIST avcodec_auto_excluded)
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip files with _template in the name (they are #included by other files)
    if("${_src_name}" MATCHES "_template\\.c$")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip tablegen files (table generation tools, not library code)
    # Exception: cbrt_tablegen_common.c defines ff_cbrt_dbl_tableinit used at runtime
    if("${_src_name}" MATCHES "tablegen")
        if(NOT "${_src_name}" STREQUAL "cbrt_tablegen_common.c")
            list(APPEND avcodec_glob_excluded "${_src_name}")
            continue()
        endif()
    endif()
    # Skip Windows-only D3D12VA files
    if("${_src_name}" MATCHES "^d3d12va_")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip Windows-only DXVA2 files
    if("${_src_name}" MATCHES "^dxva2")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip external library wrapper files (lib*.c are always external lib wrappers)
    if("${_src_name}" MATCHES "^lib[a-z]")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip OpenHarmony platform-specific files
    if("${_src_name}" MATCHES "^oh")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip Vulkan files (require newer Vulkan SDK than available)
    if("${_src_name}" MATCHES "vulkan")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip QSV files (require Intel MFX/QSV SDK)
    if("${_src_name}" MATCHES "^qsv")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip Rockchip MPP files (require Rockchip MPP SDK)
    if("${_src_name}" MATCHES "^rkmpp")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip VideoToolbox files (handled in conditional section below)
    if("${_src_name}" MATCHES "^videotoolbox\\.c$|^videotoolboxenc\\.c$")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip Android/JNI/MediaCodec files (Android only)
    if("${_src_name}" MATCHES "^mediacodec|^ffjni\\.c$|^jni\\.c$")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip NVENC/CUVID/NVDEC files (require NVIDIA ffnvcodec headers)
    if("${_src_name}" MATCHES "^nvenc|^nvdec|^cuvid|_cuvid\\.c$")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip V4L2 files (Linux-only, require linux/videodev2.h)
    if("${_src_name}" MATCHES "^v4l2")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip VAAPI files (Linux-only, require va/va.h)
    if("${_src_name}" MATCHES "^vaapi")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip VDPAU files (Linux/NVIDIA-only, require vdpau/vdpau.h)
    if("${_src_name}" MATCHES "^vdpau")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Skip MMAL files (Raspberry Pi only, require interface/mmal)
    if("${_src_name}" MATCHES "^mmal|mmaldec\\.c$")
        list(APPEND avcodec_glob_excluded "${_src_name}")
        continue()
    endif()
    # Add to sources (duplicates will be removed later)
    list(APPEND avcodec_sources "${_src_name}")
endforeach()

# ============================================================================
# Remove duplicates
# ============================================================================
list(REMOVE_DUPLICATES avcodec_sources)

# ============================================================================
# Filter out source files that don't exist (some files may have been
# reorganized into subdirectories in newer FFmpeg versions)
# ============================================================================
set(avcodec_sources_filtered "")
foreach(src IN LISTS avcodec_sources)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
        list(APPEND avcodec_sources_filtered "${src}")
    else()
        message(STATUS "avcodec: skipping missing source file: ${src}")
    endif()
endforeach()
set(avcodec_sources ${avcodec_sources_filtered})

# ============================================================================
# External library wrappers - add conditionally based on CONFIG_* variables
# These files are excluded from auto-detection above (in avcodec_external_lib_files)
# ============================================================================

# libx264 H.264 encoder
if(CONFIG_LIBX264)
    list(APPEND avcodec_sources libx264.c)
endif()

# libx265 HEVC encoder  
if(CONFIG_LIBX265)
    list(APPEND avcodec_sources libx265.c)
endif()

# lcms2 color management
if(CONFIG_LCMS2)
    list(APPEND avcodec_sources fflcms2.c)
endif()

# VideoToolbox (macOS/iOS hardware acceleration)
if(APPLE AND CONFIG_VIDEOTOOLBOX)
    list(APPEND avcodec_sources
        videotoolbox.c videotoolboxenc.c
    )
endif()

# AudioToolbox (macOS/iOS audio codecs)
if(APPLE AND CONFIG_AUDIOTOOLBOX)
    list(APPEND avcodec_sources
        audiotoolboxdec.c audiotoolboxenc.c
    )
endif()

# ============================================================================
# Generate custom codec_list.c and bsf_list.c based on actually compiled files
# Strategy: scan allcodecs.c for all extern declarations, then filter by
# checking which symbols are actually defined in compiled source files.
# This handles codecs defined via macros (like PCM codecs in pcm.c).
# ============================================================================

# Step 1: Collect all symbols declared in allcodecs.c
set(_all_codec_syms "")
set(_all_bsf_syms "")
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/allcodecs.c" _allcodecs_lines
    REGEX "^extern const (FFCodec|FFBitStreamFilter) ff_[a-zA-Z0-9_]+;")
foreach(_line IN LISTS _allcodecs_lines)
    if(_line MATCHES "extern const FFCodec (ff_[a-zA-Z0-9_]+);")
        list(APPEND _all_codec_syms "${CMAKE_MATCH_1}")
    elseif(_line MATCHES "extern const FFBitStreamFilter (ff_[a-zA-Z0-9_]+);")
        list(APPEND _all_bsf_syms "${CMAKE_MATCH_1}")
    endif()
endforeach()

# Step 2: Collect symbols from excluded files (these should NOT be in the list)
# This includes both avcodec_auto_excluded AND avcodec_glob_excluded files
set(_excluded_codec_syms "")
set(_excluded_bsf_syms "")
set(_all_excluded_files ${avcodec_auto_excluded} ${avcodec_glob_excluded})
list(REMOVE_DUPLICATES _all_excluded_files)
foreach(_excl_name IN LISTS _all_excluded_files)
    set(_excl_abs "${CMAKE_CURRENT_SOURCE_DIR}/${_excl_name}")
    if(NOT EXISTS "${_excl_abs}")
        continue()
    endif()
    # Scan for direct definitions
    file(STRINGS "${_excl_abs}" _excl_lines
        REGEX "^(const FFCodec|const FFBitStreamFilter) ff_[a-zA-Z0-9_]+ =")
    foreach(_line IN LISTS _excl_lines)
        if(_line MATCHES "const FFCodec (ff_[a-zA-Z0-9_]+)")
            list(APPEND _excluded_codec_syms "${CMAKE_MATCH_1}")
        elseif(_line MATCHES "const FFBitStreamFilter (ff_[a-zA-Z0-9_]+)")
            list(APPEND _excluded_bsf_syms "${CMAKE_MATCH_1}")
        endif()
    endforeach()
endforeach()

# Step 3: Filter - keep only symbols NOT in excluded files
set(_codec_symbols ${_all_codec_syms})
set(_bsf_symbols ${_all_bsf_syms})
if(_excluded_codec_syms)
    list(REMOVE_ITEM _codec_symbols ${_excluded_codec_syms})
endif()
if(_excluded_bsf_syms)
    list(REMOVE_ITEM _bsf_symbols ${_excluded_bsf_syms})
endif()

list(REMOVE_DUPLICATES _codec_symbols)
list(REMOVE_DUPLICATES _bsf_symbols)

# Step 4: Verify symbols actually exist in compiled sources
# Method: Use gcc -E to preprocess all source files and check which symbols survive
# This handles #if CONFIG_XXX conditional compilation correctly

set(_found_codec_syms "")
set(_found_bsf_syms "")

# Preprocess all avcodec_sources files and collect defined symbols
foreach(_src IN LISTS avcodec_sources)
    set(_src_abs "${CMAKE_CURRENT_SOURCE_DIR}/${_src}")
    if(NOT EXISTS "${_src_abs}")
        continue()
    endif()
    
    # Use gcc -E to preprocess and see which symbols are actually defined
    execute_process(
        COMMAND ${CMAKE_C_COMPILER} -E -I${CMAKE_SOURCE_DIR} -I${CMAKE_BINARY_DIR}
                -I${CMAKE_CURRENT_SOURCE_DIR}
                -DHAVE_AV_CONFIG_H -include ${CMAKE_BINARY_DIR}/config.h
                "${_src_abs}"
        OUTPUT_VARIABLE _expanded
        ERROR_QUIET
        RESULT_VARIABLE _gcc_result
        TIMEOUT 30
    )
    
    if(_gcc_result EQUAL 0)
        # Scan preprocessed output for FFCodec/FFBitStreamFilter definitions
        string(REGEX MATCHALL "const FFCodec ff_[a-zA-Z0-9_]+" _codec_matches "${_expanded}")
        string(REGEX MATCHALL "const FFBitStreamFilter ff_[a-zA-Z0-9_]+" _bsf_matches "${_expanded}")
        
        foreach(_match IN LISTS _codec_matches)
            if(_match MATCHES "const FFCodec (ff_[a-zA-Z0-9_]+)")
                list(APPEND _found_codec_syms "${CMAKE_MATCH_1}")
            endif()
        endforeach()
        
        foreach(_match IN LISTS _bsf_matches)
            if(_match MATCHES "const FFBitStreamFilter (ff_[a-zA-Z0-9_]+)")
                list(APPEND _found_bsf_syms "${CMAKE_MATCH_1}")
            endif()
        endforeach()
    endif()
endforeach()

# Remove duplicates while preserving order
list(REMOVE_DUPLICATES _found_codec_syms)
list(REMOVE_DUPLICATES _found_bsf_syms)

# Final filter: only keep symbols that were found in preprocessed output
set(_verified_codec_syms "")
foreach(_sym IN LISTS _codec_symbols)
    if("${_sym}" IN_LIST _found_codec_syms)
        list(APPEND _verified_codec_syms "${_sym}")
    endif()
endforeach()
set(_codec_symbols ${_verified_codec_syms})

# For BSFs, do the same
set(_verified_bsf_syms "")
foreach(_sym IN LISTS _bsf_symbols)
    if("${_sym}" IN_LIST _found_bsf_syms)
    endif()
endforeach()
set(_bsf_symbols ${_verified_bsf_syms})
set(_codec_list_content "static const FFCodec * const codec_list[] = {\n")
foreach(_sym IN LISTS _codec_symbols)
    string(APPEND _codec_list_content "    &${_sym},\n")
endforeach()
string(APPEND _codec_list_content "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavcodec/codec_list.c" "${_codec_list_content}")

# Generate bsf_list.c
set(_bsf_list_content "static const FFBitStreamFilter * const bitstream_filters[] = {\n")
foreach(_sym IN LISTS _bsf_symbols)
    string(APPEND _bsf_list_content "    &${_sym},\n")
endforeach()
string(APPEND _bsf_list_content "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavcodec/bsf_list.c" "${_bsf_list_content}")

# Generate allcodecs_generated.c to replace allcodecs.c
# This file contains only extern declarations for actually-compiled codecs,
# plus the codec_list[] array and all functions from the original allcodecs.c.
set(_gen_allcodecs "/*\n * Auto-generated by CMake. Do not edit.\n * Replaces allcodecs.c with only the codecs actually compiled.\n */\n")
string(APPEND _gen_allcodecs "#include <stdint.h>\n")
string(APPEND _gen_allcodecs "#include <string.h>\n")
string(APPEND _gen_allcodecs "#include \"config.h\"\n")
string(APPEND _gen_allcodecs "#include \"libavutil/thread.h\"\n")
string(APPEND _gen_allcodecs "#include \"avcodec.h\"\n")
string(APPEND _gen_allcodecs "#include \"codec.h\"\n")
string(APPEND _gen_allcodecs "#include \"codec_id.h\"\n")
string(APPEND _gen_allcodecs "#include \"codec_internal.h\"\n")
string(APPEND _gen_allcodecs "\n")
# extern declarations for codecs
foreach(_sym IN LISTS _codec_symbols)
    string(APPEND _gen_allcodecs "extern const FFCodec ${_sym};\n")
endforeach()
string(APPEND _gen_allcodecs "\n")
# inline codec_list[] array
string(APPEND _gen_allcodecs "const FFCodec * codec_list[] = {\n")
foreach(_sym IN LISTS _codec_symbols)
    string(APPEND _gen_allcodecs "    (FFCodec *)&${_sym},\n")
endforeach()
string(APPEND _gen_allcodecs "    NULL\n};\n")
string(APPEND _gen_allcodecs "\n")
# Copy the runtime functions from allcodecs.c (av_codec_iterate, avcodec_find_*, etc.)
# These do not depend on the extern declarations, only on codec_list[]
string(APPEND _gen_allcodecs "
static AVOnce av_codec_static_init = AV_ONCE_INIT;
static void av_codec_init_static(void)
{
    int dummy;
    for (int i = 0; codec_list[i]; i++) {
        const FFCodec *codec = codec_list[i];
        if (!codec->get_supported_config)
            continue;
FF_DISABLE_DEPRECATION_WARNINGS
        switch (codec->p.type) {
        case AVMEDIA_TYPE_VIDEO:
            if (!codec->p.pix_fmts)
                codec->get_supported_config(NULL, &codec->p,
                                            AV_CODEC_CONFIG_PIX_FORMAT, 0,
                                            (const void **) &codec->p.pix_fmts,
                                            &dummy);
            break;
        case AVMEDIA_TYPE_AUDIO:
            codec->get_supported_config(NULL, &codec->p,
                                        AV_CODEC_CONFIG_SAMPLE_FORMAT, 0,
                                        (const void **) &codec->p.sample_fmts,
                                        &dummy);
            codec->get_supported_config(NULL, &codec->p,
                                        AV_CODEC_CONFIG_SAMPLE_RATE, 0,
                                        (const void **) &codec->p.supported_samplerates,
                                        &dummy);
            codec->get_supported_config(NULL, &codec->p,
                                        AV_CODEC_CONFIG_CHANNEL_LAYOUT, 0,
                                        (const void **) &codec->p.ch_layouts,
                                        &dummy);
            break;
        default:
            break;
        }
FF_ENABLE_DEPRECATION_WARNINGS
    }
}

const AVCodec *av_codec_iterate(void **opaque)
{
    uintptr_t i = (uintptr_t)*opaque;
    const FFCodec *c = codec_list[i];
    ff_thread_once(&av_codec_static_init, av_codec_init_static);
    if (c) {
        *opaque = (void*)(i + 1);
        return &c->p;
    }
    return NULL;
}

static enum AVCodecID remap_deprecated_codec_id(enum AVCodecID id)
{
    switch(id){
        default: return id;
    }
}

static const AVCodec *find_codec(enum AVCodecID id, int (*x)(const AVCodec *))
{
    const AVCodec *p, *experimental = NULL;
    void *i = 0;
    id = remap_deprecated_codec_id(id);
    while ((p = av_codec_iterate(&i))) {
        if (!x(p))
            continue;
        if (p->id == id) {
            if (p->capabilities & AV_CODEC_CAP_EXPERIMENTAL && !experimental) {
                experimental = p;
            } else
                return p;
        }
    }
    return experimental;
}

const AVCodec *avcodec_find_encoder(enum AVCodecID id)
{
    return find_codec(id, ff_codec_is_encoder);
}

const AVCodec *avcodec_find_decoder(enum AVCodecID id)
{
    return find_codec(id, ff_codec_is_decoder);
}

static const AVCodec *find_codec_by_name(const char *name, int (*x)(const AVCodec *))
{
    void *i = 0;
    const AVCodec *p;
    if (!name)
        return NULL;
    while ((p = av_codec_iterate(&i))) {
        if (!x(p))
            continue;
        if (strcmp(name, p->name) == 0)
            return p;
    }
    return NULL;
}

const AVCodec *avcodec_find_encoder_by_name(const char *name)
{
    return find_codec_by_name(name, ff_codec_is_encoder);
}

const AVCodec *avcodec_find_decoder_by_name(const char *name)
{
    return find_codec_by_name(name, ff_codec_is_decoder);
}
")
file(WRITE "${CMAKE_BINARY_DIR}/libavcodec/allcodecs_generated.c" "${_gen_allcodecs}")

list(LENGTH _codec_symbols _n_codecs)
list(LENGTH _bsf_symbols _n_bsfs)
message(STATUS "libavcodec: generated allcodecs_generated.c with ${_n_codecs} codecs")
message(STATUS "libavcodec: generated bsf_list.c with ${_n_bsfs} BSFs")

# Add generated directory to include path
include_directories("${CMAKE_BINARY_DIR}")
add_library(avcodec STATIC ${avcodec_sources}
    "${CMAKE_BINARY_DIR}/libavcodec/allcodecs_generated.c")

# Include directories
target_include_directories(avcodec
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

# Add source directory as NASM include path for each .asm file
if(ARCH_X86 AND ENABLE_ASM AND HAVE_X86ASM)
    nasm_add_source_dir_includes(avcodec)
endif()

# Link dependencies
target_link_libraries(avcodec
    PRIVATE
        swresample
        avutil
        Threads::Threads
)

# Link optional external libraries (standard CMake packages)
if(CONFIG_ZLIB AND ZLIB_FOUND)
    target_link_libraries(avcodec PRIVATE ZLIB::ZLIB)
endif()
if(CONFIG_LZMA AND LIBLZMA_FOUND)
    target_link_libraries(avcodec PRIVATE LibLZMA::LibLZMA)
endif()
if(CONFIG_BZLIB AND BZIP2_FOUND)
    target_link_libraries(avcodec PRIVATE BZip2::BZip2)
endif()

# External library include/link are handled centrally in cmake/FFmpegApplyExternalLibs.cmake

# Apple frameworks (macOS/iOS)
if(APPLE)
    if(CONFIG_AUDIOTOOLBOX)
        target_link_libraries(avcodec PRIVATE "-framework AudioToolbox" "-framework CoreFoundation")
    endif()
    if(CONFIG_VIDEOTOOLBOX)
        target_link_libraries(avcodec PRIVATE
            "-framework VideoToolbox"
            "-framework CoreVideo"
            "-framework CoreMedia"
            "-framework CoreFoundation"
        )
    endif()
endif()

# Compiler definitions
target_compile_definitions(avcodec PRIVATE
    HAVE_AV_CONFIG_H
    BUILDING_avcodec
)

# Position independent code for shared builds
set_pic_if_needed(avcodec)

# Set output name
set_target_properties(avcodec PROPERTIES
    OUTPUT_NAME avcodec
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

message(STATUS "libavcodec configured")
