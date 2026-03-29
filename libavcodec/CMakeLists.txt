# libavcodec CMakeLists.txt
# Generated from libavcodec/Makefile by tools/gen_avcodec_cmake.py
# All source files are listed explicitly (no file(GLOB) usage).

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
# Conditional sources based on CONFIG_* variables
# (from OBJS-$(CONFIG_*) in Makefile and subdirectory Makefiles)
# ============================================================================

# --- Internal subsystems ---
if(CONFIG_AANDCTTABLES)
    list(APPEND avcodec_sources aandcttab.c)
endif()

if(CONFIG_AC3DSP)
    list(APPEND avcodec_sources ac3dsp.c)
    list(APPEND avcodec_sources ac3.c)
    list(APPEND avcodec_sources ac3tab.c)
endif()

if(CONFIG_ADTS_HEADER)
    list(APPEND avcodec_sources adts_header.c)
    list(APPEND avcodec_sources mpeg4audio_sample_rates.c)
endif()

if(CONFIG_AMF)
    list(APPEND avcodec_sources amfenc.c)
    list(APPEND avcodec_sources amfdec.c)
endif()

if(CONFIG_AUDIO_FRAME_QUEUE)
    list(APPEND avcodec_sources audio_frame_queue.c)
endif()

if(CONFIG_ATSC_A53)
    list(APPEND avcodec_sources atsc_a53.c)
endif()

if(CONFIG_AUDIODSP)
    list(APPEND avcodec_sources audiodsp.c)
endif()

if(CONFIG_BLOCKDSP)
    list(APPEND avcodec_sources blockdsp.c)
endif()

if(CONFIG_BSWAPDSP)
    list(APPEND avcodec_sources bswapdsp.c)
endif()

if(CONFIG_CABAC)
    list(APPEND avcodec_sources cabac.c)
endif()

if(CONFIG_CBS)
    list(APPEND avcodec_sources cbs.c)
    list(APPEND avcodec_sources cbs_bsf.c)
endif()

if(CONFIG_CBS_APV)
    list(APPEND avcodec_sources cbs_apv.c)
endif()

if(CONFIG_CBS_AV1)
    list(APPEND avcodec_sources cbs_av1.c)
endif()

if(CONFIG_CBS_H264)
    list(APPEND avcodec_sources cbs_h264.c)
    list(APPEND avcodec_sources cbs_h2645.c)
    list(APPEND avcodec_sources cbs_sei.c)
    list(APPEND avcodec_sources h2645_parse.c)
endif()

if(CONFIG_CBS_H265)
    list(APPEND avcodec_sources cbs_h265.c)
    list(APPEND avcodec_sources cbs_h2645.c)
    list(APPEND avcodec_sources cbs_sei.c)
    list(APPEND avcodec_sources h2645_parse.c)
endif()

if(CONFIG_CBS_H266)
    list(APPEND avcodec_sources cbs_h266.c)
    list(APPEND avcodec_sources cbs_h2645.c)
    list(APPEND avcodec_sources cbs_sei.c)
    list(APPEND avcodec_sources h2645_parse.c)
endif()

if(CONFIG_CBS_LCEVC)
    list(APPEND avcodec_sources cbs_lcevc.c)
    list(APPEND avcodec_sources cbs_h2645.c)
    list(APPEND avcodec_sources cbs_sei.c)
    list(APPEND avcodec_sources h2645_parse.c)
endif()

if(CONFIG_CBS_JPEG)
    list(APPEND avcodec_sources cbs_jpeg.c)
endif()

if(CONFIG_CBS_MPEG2)
    list(APPEND avcodec_sources cbs_mpeg2.c)
endif()

if(CONFIG_CBS_VP8)
    list(APPEND avcodec_sources cbs_vp8.c)
    list(APPEND avcodec_sources vp8data.c)
endif()

if(CONFIG_CBS_VP9)
    list(APPEND avcodec_sources cbs_vp9.c)
endif()

if(CONFIG_CELP_MATH)
    list(APPEND avcodec_sources celp_math.c)
endif()

if(CONFIG_D3D12VA_ENCODE)
    list(APPEND avcodec_sources d3d12va_encode.c)
    list(APPEND avcodec_sources hw_base_encode.c)
endif()

if(CONFIG_DEFLATE_WRAPPER)
    list(APPEND avcodec_sources zlib_wrapper.c)
endif()

if(CONFIG_DOVI_RPUDEC)
    list(APPEND avcodec_sources dovi_rpu.c)
    list(APPEND avcodec_sources dovi_rpudec.c)
endif()

if(CONFIG_DOVI_RPUENC)
    list(APPEND avcodec_sources dovi_rpu.c)
    list(APPEND avcodec_sources dovi_rpuenc.c)
endif()

if(CONFIG_ERROR_RESILIENCE)
    list(APPEND avcodec_sources error_resilience.c)
endif()

if(CONFIG_EVCPARSE)
    list(APPEND avcodec_sources evc_parse.c)
    list(APPEND avcodec_sources evc_ps.c)
endif()

if(CONFIG_FAANDCT)
    list(APPEND avcodec_sources faandct.c)
endif()

if(CONFIG_FAANIDCT)
    list(APPEND avcodec_sources faanidct.c)
endif()

if(CONFIG_FDCTDSP)
    list(APPEND avcodec_sources fdctdsp.c)
    list(APPEND avcodec_sources jfdctfst.c)
    list(APPEND avcodec_sources jfdctint.c)
endif()

if(CONFIG_FMTCONVERT)
    list(APPEND avcodec_sources fmtconvert.c)
endif()

if(CONFIG_GOLOMB)
    list(APPEND avcodec_sources golomb.c)
endif()

if(CONFIG_H263DSP)
    list(APPEND avcodec_sources h263dsp.c)
endif()

if(CONFIG_H264CHROMA)
    list(APPEND avcodec_sources h264chroma.c)
endif()

if(CONFIG_H264DSP)
    list(APPEND avcodec_sources h264dsp.c)
    list(APPEND avcodec_sources h264idct.c)
endif()

if(CONFIG_H264PARSE)
    list(APPEND avcodec_sources h264_parse.c)
    list(APPEND avcodec_sources h264_ps.c)
    list(APPEND avcodec_sources h264data.c)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources h2645_parse.c)
    list(APPEND avcodec_sources h2645_vui.c)
endif()

if(CONFIG_H264PRED)
    list(APPEND avcodec_sources h264pred.c)
endif()

if(CONFIG_H264QPEL)
    list(APPEND avcodec_sources h264qpel.c)
endif()

if(CONFIG_H264_SEI)
    list(APPEND avcodec_sources h264_sei.c)
    list(APPEND avcodec_sources h2645_sei.c)
    list(APPEND avcodec_sources aom_film_grain.c)
endif()

if(CONFIG_HEVCPARSE)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources h2645_parse.c)
    list(APPEND avcodec_sources h2645_vui.c)
    list(APPEND avcodec_sources hevc/data.c)
    list(APPEND avcodec_sources hevc/parse.c)
    list(APPEND avcodec_sources hevc/ps.c)
endif()

if(CONFIG_HEVC_SEI)
    list(APPEND avcodec_sources h2645_sei.c)
    list(APPEND avcodec_sources aom_film_grain.c)
    list(APPEND avcodec_sources dynamic_hdr_vivid.c)
    list(APPEND avcodec_sources hevc/sei.c)
endif()

if(CONFIG_HPELDSP)
    list(APPEND avcodec_sources hpeldsp.c)
endif()

if(CONFIG_HUFFMAN)
    list(APPEND avcodec_sources huffman.c)
endif()

if(CONFIG_HUFFYUVDSP)
    list(APPEND avcodec_sources huffyuvdsp.c)
endif()

if(CONFIG_HUFFYUVENCDSP)
    list(APPEND avcodec_sources huffyuvencdsp.c)
endif()

if(CONFIG_IDCTDSP)
    list(APPEND avcodec_sources idctdsp.c)
    list(APPEND avcodec_sources simple_idct.c)
    list(APPEND avcodec_sources jrevdct.c)
endif()

if(CONFIG_INFLATE_WRAPPER)
    list(APPEND avcodec_sources zlib_wrapper.c)
endif()

if(CONFIG_INTRAX8)
    list(APPEND avcodec_sources intrax8.c)
    list(APPEND avcodec_sources intrax8dsp.c)
    list(APPEND avcodec_sources msmpeg4_vc1_data.c)
endif()

if(CONFIG_IVIDSP)
    list(APPEND avcodec_sources ivi_dsp.c)
endif()

if(CONFIG_JNI)
    list(APPEND avcodec_sources ffjni.c)
    list(APPEND avcodec_sources jni.c)
endif()

if(CONFIG_JPEGTABLES)
    list(APPEND avcodec_sources jpegtables.c)
endif()

if(CONFIG_LCMS2)
    list(APPEND avcodec_sources fflcms2.c)
endif()

if(CONFIG_LIBLCEVC_DEC)
    list(APPEND avcodec_sources lcevcdec.c)
    list(APPEND avcodec_sources lcevctab.c)
endif()

if(CONFIG_LLAUDDSP)
    list(APPEND avcodec_sources lossless_audiodsp.c)
endif()

if(CONFIG_LLVIDDSP)
    list(APPEND avcodec_sources lossless_videodsp.c)
endif()

if(CONFIG_LLVIDENCDSP)
    list(APPEND avcodec_sources lossless_videoencdsp.c)
endif()

if(CONFIG_LPC)
    list(APPEND avcodec_sources lpc.c)
endif()

if(CONFIG_LSP)
    list(APPEND avcodec_sources lsp.c)
endif()

if(CONFIG_LZF)
    list(APPEND avcodec_sources lzf.c)
endif()

if(CONFIG_ME_CMP)
    list(APPEND avcodec_sources me_cmp.c)
endif()

if(CONFIG_MEDIACODEC)
    list(APPEND avcodec_sources mediacodecdec_common.c)
    list(APPEND avcodec_sources mediacodec_surface.c)
    list(APPEND avcodec_sources mediacodec_wrapper.c)
    list(APPEND avcodec_sources mediacodec_sw_buffer.c)
endif()

if(CONFIG_MPEG_ER)
    list(APPEND avcodec_sources mpeg_er.c)
endif()

if(CONFIG_MPEGAUDIO)
    list(APPEND avcodec_sources mpegaudio.c)
    list(APPEND avcodec_sources mpegaudiodec_common.c)
    list(APPEND avcodec_sources mpegaudiodata.c)
endif()

if(CONFIG_MPEGAUDIODSP)
    list(APPEND avcodec_sources mpegaudiodsp.c)
    list(APPEND avcodec_sources mpegaudiodsp_data.c)
    list(APPEND avcodec_sources mpegaudiodsp_fixed.c)
    list(APPEND avcodec_sources mpegaudiodsp_float.c)
    list(APPEND avcodec_sources dct32_fixed.c)
    list(APPEND avcodec_sources dct32_float.c)
endif()

if(CONFIG_MPEGAUDIOHEADER)
    list(APPEND avcodec_sources mpegaudiodecheader.c)
    list(APPEND avcodec_sources mpegaudiotabs.c)
endif()

if(CONFIG_MPEG4AUDIO)
    list(APPEND avcodec_sources mpeg4audio.c)
    list(APPEND avcodec_sources mpeg4audio_sample_rates.c)
endif()

if(CONFIG_MPEGVIDEO)
    list(APPEND avcodec_sources mpegvideo.c)
    list(APPEND avcodec_sources rl.c)
    list(APPEND avcodec_sources mpegvideo_motion.c)
    list(APPEND avcodec_sources mpegvideo_unquantize.c)
    list(APPEND avcodec_sources mpegvideodata.c)
    list(APPEND avcodec_sources mpegpicture.c)
    list(APPEND avcodec_sources to_upper4.c)
endif()

if(CONFIG_MPEGVIDEODEC)
    list(APPEND avcodec_sources mpegvideo_dec.c)
    list(APPEND avcodec_sources mpegutils.c)
endif()

if(CONFIG_MPEGVIDEOENC)
    list(APPEND avcodec_sources mpegvideo_enc.c)
    list(APPEND avcodec_sources mpeg12data.c)
    list(APPEND avcodec_sources motion_est.c)
    list(APPEND avcodec_sources ratecontrol.c)
endif()

if(CONFIG_MPEGVIDEOENCDSP)
    list(APPEND avcodec_sources mpegvideoencdsp.c)
endif()

if(CONFIG_MSMPEG4DEC)
    list(APPEND avcodec_sources msmpeg4dec.c)
    list(APPEND avcodec_sources msmpeg4.c)
    list(APPEND avcodec_sources msmpeg4data.c)
    list(APPEND avcodec_sources msmpeg4_vc1_data.c)
    list(APPEND avcodec_sources mpeg4videodec.c)
endif()

if(CONFIG_MSMPEG4ENC)
    list(APPEND avcodec_sources msmpeg4enc.c)
    list(APPEND avcodec_sources msmpeg4.c)
    list(APPEND avcodec_sources msmpeg4data.c)
    list(APPEND avcodec_sources msmpeg4_vc1_data.c)
endif()

if(CONFIG_MSS34DSP)
    list(APPEND avcodec_sources mss34dsp.c)
    list(APPEND avcodec_sources jpegquanttables.c)
endif()

if(CONFIG_PIXBLOCKDSP)
    list(APPEND avcodec_sources pixblockdsp.c)
endif()

if(CONFIG_QPELDSP)
    list(APPEND avcodec_sources qpeldsp.c)
endif()

if(CONFIG_QSV)
    list(APPEND avcodec_sources qsv.c)
endif()

if(CONFIG_QSVDEC)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_QSVENC)
    list(APPEND avcodec_sources qsvenc.c)
endif()

if(CONFIG_RANGECODER)
    list(APPEND avcodec_sources rangecoder.c)
endif()

if(CONFIG_RV34DSP)
    list(APPEND avcodec_sources rv34dsp.c)
endif()

if(CONFIG_SINEWIN)
    list(APPEND avcodec_sources sinewin.c)
endif()

if(CONFIG_SMPTE_436M)
    list(APPEND avcodec_sources smpte_436m.c)
endif()

if(CONFIG_SNAPPY)
    list(APPEND avcodec_sources snappy.c)
endif()

if(CONFIG_STARTCODE)
    list(APPEND avcodec_sources startcode.c)
endif()

if(CONFIG_TEXTUREDSP)
    list(APPEND avcodec_sources texturedsp.c)
endif()

if(CONFIG_TEXTUREDSPENC)
    list(APPEND avcodec_sources texturedspenc.c)
endif()

if(CONFIG_TPELDSP)
    list(APPEND avcodec_sources tpeldsp.c)
endif()

if(CONFIG_VAAPI_ENCODE)
    list(APPEND avcodec_sources vaapi_encode.c)
    list(APPEND avcodec_sources hw_base_encode.c)
endif()

if(CONFIG_VC1DSP)
    list(APPEND avcodec_sources vc1dsp.c)
endif()

if(CONFIG_VIDEODSP)
    list(APPEND avcodec_sources videodsp.c)
endif()

if(CONFIG_VP3DSP)
    list(APPEND avcodec_sources vp3dsp.c)
endif()

if(CONFIG_VP8DSP)
    list(APPEND avcodec_sources vp8dsp.c)
endif()

if(CONFIG_V4L2_M2M)
    list(APPEND avcodec_sources v4l2_m2m.c)
    list(APPEND avcodec_sources v4l2_context.c)
    list(APPEND avcodec_sources v4l2_buffers.c)
    list(APPEND avcodec_sources v4l2_fmt.c)
endif()

if(CONFIG_WMA_FREQS)
    list(APPEND avcodec_sources wma_freqs.c)
endif()

if(CONFIG_WMV2DSP)
    list(APPEND avcodec_sources wmv2dsp.c)
endif()

if(CONFIG_VVC_SEI)
    list(APPEND avcodec_sources h2645_sei.c)
    list(APPEND avcodec_sources aom_film_grain.c)
    list(APPEND avcodec_sources h274.c)
endif()

if(CONFIG_D3D11VA)
    list(APPEND avcodec_sources dxva2.c)
endif()

if(CONFIG_D3D12VA)
    list(APPEND avcodec_sources dxva2.c)
    list(APPEND avcodec_sources d3d12va_decode.c)
endif()

if(CONFIG_DXVA2)
    list(APPEND avcodec_sources dxva2.c)
endif()

if(CONFIG_NVDEC)
    list(APPEND avcodec_sources nvdec.c)
endif()

if(CONFIG_VAAPI)
    list(APPEND avcodec_sources vaapi_decode.c)
endif()

if(CONFIG_VIDEOTOOLBOX)
    list(APPEND avcodec_sources videotoolbox.c)
endif()

if(CONFIG_VDPAU)
    list(APPEND avcodec_sources vdpau.c)
endif()

if(CONFIG_VULKAN)
    list(APPEND avcodec_sources vulkan.c)
    list(APPEND avcodec_sources vulkan_video.c)
endif()

if(CONFIG_FITS_DEMUXER)
    list(APPEND avcodec_sources fits.c)
endif()

if(CONFIG_TAK_DEMUXER)
    list(APPEND avcodec_sources tak.c)
endif()

if(CONFIG_ELBG_FILTER)
    list(APPEND avcodec_sources elbg.c)
endif()

# ============================================================================
# Decoder sources (CONFIG_*_DECODER)
# ============================================================================

if(CONFIG_AV1_AMF_DECODER)
    list(APPEND avcodec_sources amfdec.c)
endif()

if(CONFIG_ZERO12V_DECODER)
    list(APPEND avcodec_sources 012v.c)
endif()

if(CONFIG_AAC_DECODER)
    list(APPEND avcodec_sources aactab.c)
    list(APPEND avcodec_sources aacsbr.c)
    list(APPEND avcodec_sources aacps_common.c)
    list(APPEND avcodec_sources aacps_float.c)
    list(APPEND avcodec_sources kbdwin.c)
    list(APPEND avcodec_sources sbrdsp.c)
    list(APPEND avcodec_sources aacpsdsp_float.c)
    list(APPEND avcodec_sources cbrt_data.c)
    list(APPEND avcodec_sources aac/aacdec.c)
    list(APPEND avcodec_sources aac/aacdec_tab.c)
    list(APPEND avcodec_sources aac/aacdec_float.c)
    list(APPEND avcodec_sources aac/aacdec_usac.c)
    list(APPEND avcodec_sources aac/aacdec_ac.c)
    list(APPEND avcodec_sources aac/aacdec_lpd.c)
    list(APPEND avcodec_sources aac/aacdec_usac_mps212.c)
endif()

if(CONFIG_AAC_FIXED_DECODER)
    list(APPEND avcodec_sources aactab.c)
    list(APPEND avcodec_sources aacsbr_fixed.c)
    list(APPEND avcodec_sources aacps_common.c)
    list(APPEND avcodec_sources aacps_fixed.c)
    list(APPEND avcodec_sources kbdwin.c)
    list(APPEND avcodec_sources sbrdsp_fixed.c)
    list(APPEND avcodec_sources aacpsdsp_fixed.c)
    list(APPEND avcodec_sources cbrt_data_fixed.c)
    list(APPEND avcodec_sources aac/aacdec.c)
    list(APPEND avcodec_sources aac/aacdec_tab.c)
    list(APPEND avcodec_sources aac/aacdec_fixed.c)
endif()

if(CONFIG_AAC_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_AASC_DECODER)
    list(APPEND avcodec_sources aasc.c)
    list(APPEND avcodec_sources msrledec.c)
endif()

if(CONFIG_AC3_DECODER)
    list(APPEND avcodec_sources ac3dec_float.c)
    list(APPEND avcodec_sources ac3dec_data.c)
    list(APPEND avcodec_sources ac3.c)
    list(APPEND avcodec_sources kbdwin.c)
    list(APPEND avcodec_sources ac3tab.c)
    list(APPEND avcodec_sources ac3_channel_layout_tab.c)
endif()

if(CONFIG_AC3_FIXED_DECODER)
    list(APPEND avcodec_sources ac3dec_fixed.c)
    list(APPEND avcodec_sources ac3dec_data.c)
    list(APPEND avcodec_sources ac3.c)
    list(APPEND avcodec_sources kbdwin.c)
    list(APPEND avcodec_sources ac3tab.c)
    list(APPEND avcodec_sources ac3_channel_layout_tab.c)
endif()

if(CONFIG_ACELP_KELVIN_DECODER)
    list(APPEND avcodec_sources g729dec.c)
    list(APPEND avcodec_sources lsp.c)
    list(APPEND avcodec_sources celp_filters.c)
    list(APPEND avcodec_sources acelp_filters.c)
    list(APPEND avcodec_sources acelp_pitch_delay.c)
    list(APPEND avcodec_sources acelp_vectors.c)
    list(APPEND avcodec_sources g729postfilter.c)
endif()

if(CONFIG_AGM_DECODER)
    list(APPEND avcodec_sources agm.c)
    list(APPEND avcodec_sources jpegquanttables.c)
endif()

if(CONFIG_AHX_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_float.c)
endif()

if(CONFIG_AIC_DECODER)
    list(APPEND avcodec_sources aic.c)
endif()

if(CONFIG_ALAC_DECODER)
    list(APPEND avcodec_sources alac.c)
    list(APPEND avcodec_sources alac_data.c)
    list(APPEND avcodec_sources alacdsp.c)
endif()

if(CONFIG_ALIAS_PIX_DECODER)
    list(APPEND avcodec_sources aliaspixdec.c)
endif()

if(CONFIG_ALS_DECODER)
    list(APPEND avcodec_sources alsdec.c)
    list(APPEND avcodec_sources bgmc.c)
    list(APPEND avcodec_sources mlz.c)
endif()

if(CONFIG_AMRNB_DECODER)
    list(APPEND avcodec_sources amrnbdec.c)
    list(APPEND avcodec_sources celp_filters.c)
    list(APPEND avcodec_sources acelp_filters.c)
    list(APPEND avcodec_sources acelp_vectors.c)
    list(APPEND avcodec_sources acelp_pitch_delay.c)
endif()

if(CONFIG_AMRWB_DECODER)
    list(APPEND avcodec_sources amrwbdec.c)
    list(APPEND avcodec_sources celp_filters.c)
    list(APPEND avcodec_sources acelp_filters.c)
    list(APPEND avcodec_sources acelp_vectors.c)
    list(APPEND avcodec_sources acelp_pitch_delay.c)
endif()

if(CONFIG_AMRNB_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_AMRWB_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_ANM_DECODER)
    list(APPEND avcodec_sources anm.c)
endif()

if(CONFIG_ANULL_DECODER)
    list(APPEND avcodec_sources null.c)
endif()

if(CONFIG_ANSI_DECODER)
    list(APPEND avcodec_sources ansi.c)
    list(APPEND avcodec_sources cga_data.c)
endif()

if(CONFIG_APAC_DECODER)
    list(APPEND avcodec_sources apac.c)
endif()

if(CONFIG_APE_DECODER)
    list(APPEND avcodec_sources apedec.c)
endif()

if(CONFIG_APTX_DECODER)
    list(APPEND avcodec_sources aptxdec.c)
    list(APPEND avcodec_sources aptx.c)
endif()

if(CONFIG_APTX_HD_DECODER)
    list(APPEND avcodec_sources aptxdec.c)
    list(APPEND avcodec_sources aptx.c)
endif()

if(CONFIG_APNG_DECODER)
    list(APPEND avcodec_sources png.c)
    list(APPEND avcodec_sources pngdec.c)
    list(APPEND avcodec_sources pngdsp.c)
endif()

if(CONFIG_APV_DECODER)
    list(APPEND avcodec_sources apv_decode.c)
    list(APPEND avcodec_sources apv_entropy.c)
    list(APPEND avcodec_sources apv_dsp.c)
endif()

if(CONFIG_ARBC_DECODER)
    list(APPEND avcodec_sources arbc.c)
endif()

if(CONFIG_ARGO_DECODER)
    list(APPEND avcodec_sources argo.c)
endif()

if(CONFIG_SSA_DECODER)
    list(APPEND avcodec_sources assdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_ASS_DECODER)
    list(APPEND avcodec_sources assdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_ASV1_DECODER)
    list(APPEND avcodec_sources asvdec.c)
    list(APPEND avcodec_sources asv.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_ASV2_DECODER)
    list(APPEND avcodec_sources asvdec.c)
    list(APPEND avcodec_sources asv.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_ATRAC1_DECODER)
    list(APPEND avcodec_sources atrac1.c)
    list(APPEND avcodec_sources atrac.c)
endif()

if(CONFIG_ATRAC3_DECODER)
    list(APPEND avcodec_sources atrac3.c)
    list(APPEND avcodec_sources atrac.c)
endif()

if(CONFIG_ATRAC3AL_DECODER)
    list(APPEND avcodec_sources atrac3.c)
    list(APPEND avcodec_sources atrac.c)
endif()

if(CONFIG_ATRAC3P_DECODER)
    list(APPEND avcodec_sources atrac3plusdec.c)
    list(APPEND avcodec_sources atrac3plus.c)
    list(APPEND avcodec_sources atrac3plusdsp.c)
    list(APPEND avcodec_sources atrac.c)
endif()

if(CONFIG_ATRAC3PAL_DECODER)
    list(APPEND avcodec_sources atrac3plusdec.c)
    list(APPEND avcodec_sources atrac3plus.c)
    list(APPEND avcodec_sources atrac3plusdsp.c)
    list(APPEND avcodec_sources atrac.c)
endif()

if(CONFIG_ATRAC9_DECODER)
    list(APPEND avcodec_sources atrac9dec.c)
endif()

if(CONFIG_AURA_DECODER)
    list(APPEND avcodec_sources cyuv.c)
endif()

if(CONFIG_AURA2_DECODER)
    list(APPEND avcodec_sources aura.c)
endif()

if(CONFIG_AV1_DECODER)
    list(APPEND avcodec_sources av1dec.c)
    list(APPEND avcodec_sources av1_parse.c)
endif()

if(CONFIG_AV1_CUVID_DECODER)
    list(APPEND avcodec_sources cuviddec.c)
endif()

if(CONFIG_AV1_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_AVRN_DECODER)
    list(APPEND avcodec_sources avrndec.c)
endif()

if(CONFIG_AVRP_DECODER)
    list(APPEND avcodec_sources r210dec.c)
endif()

if(CONFIG_AVS_DECODER)
    list(APPEND avcodec_sources avs.c)
endif()

if(CONFIG_AVUI_DECODER)
    list(APPEND avcodec_sources avuidec.c)
endif()

if(CONFIG_BETHSOFTVID_DECODER)
    list(APPEND avcodec_sources bethsoftvideo.c)
endif()

if(CONFIG_BFI_DECODER)
    list(APPEND avcodec_sources bfi.c)
endif()

if(CONFIG_BINK_DECODER)
    list(APPEND avcodec_sources bink.c)
    list(APPEND avcodec_sources binkdsp.c)
endif()

if(CONFIG_BINKAUDIO_DCT_DECODER)
    list(APPEND avcodec_sources binkaudio.c)
endif()

if(CONFIG_BINKAUDIO_RDFT_DECODER)
    list(APPEND avcodec_sources binkaudio.c)
endif()

if(CONFIG_BINTEXT_DECODER)
    list(APPEND avcodec_sources bintext.c)
    list(APPEND avcodec_sources cga_data.c)
endif()

if(CONFIG_BITPACKED_DECODER)
    list(APPEND avcodec_sources bitpacked_dec.c)
endif()

if(CONFIG_BMP_DECODER)
    list(APPEND avcodec_sources bmp.c)
    list(APPEND avcodec_sources msrledec.c)
endif()

if(CONFIG_BMV_AUDIO_DECODER)
    list(APPEND avcodec_sources bmvaudio.c)
endif()

if(CONFIG_BMV_VIDEO_DECODER)
    list(APPEND avcodec_sources bmvvideo.c)
endif()

if(CONFIG_BONK_DECODER)
    list(APPEND avcodec_sources bonk.c)
endif()

if(CONFIG_BRENDER_PIX_DECODER)
    list(APPEND avcodec_sources brenderpix.c)
endif()

if(CONFIG_C93_DECODER)
    list(APPEND avcodec_sources c93.c)
endif()

if(CONFIG_CAVS_DECODER)
    list(APPEND avcodec_sources cavs.c)
    list(APPEND avcodec_sources cavsdec.c)
    list(APPEND avcodec_sources cavsdsp.c)
    list(APPEND avcodec_sources cavsdata.c)
endif()

if(CONFIG_CBD2_DPCM_DECODER)
    list(APPEND avcodec_sources dpcm.c)
endif()

if(CONFIG_CCAPTION_DECODER)
    list(APPEND avcodec_sources ccaption_dec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_CDGRAPHICS_DECODER)
    list(APPEND avcodec_sources cdgraphics.c)
endif()

if(CONFIG_CDTOONS_DECODER)
    list(APPEND avcodec_sources cdtoons.c)
endif()

if(CONFIG_CDXL_DECODER)
    list(APPEND avcodec_sources cdxl.c)
endif()

if(CONFIG_CFHD_DECODER)
    list(APPEND avcodec_sources cfhd.c)
    list(APPEND avcodec_sources cfhddata.c)
    list(APPEND avcodec_sources cfhddsp.c)
endif()

if(CONFIG_CINEPAK_DECODER)
    list(APPEND avcodec_sources cinepak.c)
endif()

if(CONFIG_CLEARVIDEO_DECODER)
    list(APPEND avcodec_sources clearvideo.c)
endif()

if(CONFIG_CLJR_DECODER)
    list(APPEND avcodec_sources cljrdec.c)
endif()

if(CONFIG_CLLC_DECODER)
    list(APPEND avcodec_sources cllc.c)
    list(APPEND avcodec_sources canopus.c)
endif()

if(CONFIG_COMFORTNOISE_DECODER)
    list(APPEND avcodec_sources cngdec.c)
    list(APPEND avcodec_sources celp_filters.c)
endif()

if(CONFIG_COOK_DECODER)
    list(APPEND avcodec_sources cook.c)
endif()

if(CONFIG_CPIA_DECODER)
    list(APPEND avcodec_sources cpia.c)
endif()

if(CONFIG_CRI_DECODER)
    list(APPEND avcodec_sources cri.c)
endif()

if(CONFIG_CSCD_DECODER)
    list(APPEND avcodec_sources cscd.c)
endif()

if(CONFIG_CYUV_DECODER)
    list(APPEND avcodec_sources cyuv.c)
endif()

if(CONFIG_DCA_DECODER)
    list(APPEND avcodec_sources dcadec.c)
    list(APPEND avcodec_sources dca.c)
    list(APPEND avcodec_sources dcadata.c)
    list(APPEND avcodec_sources dcahuff.c)
    list(APPEND avcodec_sources dca_core.c)
    list(APPEND avcodec_sources dca_exss.c)
    list(APPEND avcodec_sources dca_xll.c)
    list(APPEND avcodec_sources dca_lbr.c)
    list(APPEND avcodec_sources dcadsp.c)
    list(APPEND avcodec_sources dcadct.c)
    list(APPEND avcodec_sources dca_sample_rate_tab.c)
    list(APPEND avcodec_sources synth_filter.c)
endif()

if(CONFIG_DDS_DECODER)
    list(APPEND avcodec_sources dds.c)
endif()

if(CONFIG_DERF_DPCM_DECODER)
    list(APPEND avcodec_sources dpcm.c)
endif()

if(CONFIG_DIRAC_DECODER)
    list(APPEND avcodec_sources diracdec.c)
    list(APPEND avcodec_sources dirac.c)
    list(APPEND avcodec_sources diracdsp.c)
    list(APPEND avcodec_sources diractab.c)
    list(APPEND avcodec_sources dirac_arith.c)
    list(APPEND avcodec_sources dirac_dwt.c)
    list(APPEND avcodec_sources dirac_vlc.c)
endif()

if(CONFIG_DFA_DECODER)
    list(APPEND avcodec_sources dfa.c)
endif()

if(CONFIG_DFPWM_DECODER)
    list(APPEND avcodec_sources dfpwmdec.c)
endif()

if(CONFIG_DNXHD_DECODER)
    list(APPEND avcodec_sources dnxhddec.c)
    list(APPEND avcodec_sources dnxhddata.c)
endif()

if(CONFIG_DOLBY_E_DECODER)
    list(APPEND avcodec_sources dolby_e.c)
    list(APPEND avcodec_sources dolby_e_parse.c)
    list(APPEND avcodec_sources kbdwin.c)
endif()

if(CONFIG_DPX_DECODER)
    list(APPEND avcodec_sources dpx.c)
endif()

if(CONFIG_DSD_LSBF_DECODER)
    list(APPEND avcodec_sources dsddec.c)
    list(APPEND avcodec_sources dsd.c)
endif()

if(CONFIG_DSD_MSBF_DECODER)
    list(APPEND avcodec_sources dsddec.c)
    list(APPEND avcodec_sources dsd.c)
endif()

if(CONFIG_DSD_LSBF_PLANAR_DECODER)
    list(APPEND avcodec_sources dsddec.c)
    list(APPEND avcodec_sources dsd.c)
endif()

if(CONFIG_DSD_MSBF_PLANAR_DECODER)
    list(APPEND avcodec_sources dsddec.c)
    list(APPEND avcodec_sources dsd.c)
endif()

if(CONFIG_DSICINAUDIO_DECODER)
    list(APPEND avcodec_sources dsicinaudio.c)
endif()

if(CONFIG_DSICINVIDEO_DECODER)
    list(APPEND avcodec_sources dsicinvideo.c)
endif()

if(CONFIG_DSS_SP_DECODER)
    list(APPEND avcodec_sources dss_sp.c)
endif()

if(CONFIG_DST_DECODER)
    list(APPEND avcodec_sources dstdec.c)
    list(APPEND avcodec_sources dsd.c)
endif()

if(CONFIG_DVBSUB_DECODER)
    list(APPEND avcodec_sources dvbsubdec.c)
endif()

if(CONFIG_DVDSUB_DECODER)
    list(APPEND avcodec_sources dvdsubdec.c)
    list(APPEND avcodec_sources dvdsub.c)
endif()

if(CONFIG_DVAUDIO_DECODER)
    list(APPEND avcodec_sources dvaudiodec.c)
endif()

if(CONFIG_DVVIDEO_DECODER)
    list(APPEND avcodec_sources dvdec.c)
    list(APPEND avcodec_sources dv.c)
    list(APPEND avcodec_sources dvdata.c)
endif()

if(CONFIG_DXA_DECODER)
    list(APPEND avcodec_sources dxa.c)
endif()

if(CONFIG_DXTORY_DECODER)
    list(APPEND avcodec_sources dxtory.c)
endif()

if(CONFIG_DXV_DECODER)
    list(APPEND avcodec_sources dxv.c)
endif()

if(CONFIG_EAC3_DECODER)
    list(APPEND avcodec_sources eac3_data.c)
endif()

if(CONFIG_EACMV_DECODER)
    list(APPEND avcodec_sources eacmv.c)
endif()

if(CONFIG_EAMAD_DECODER)
    list(APPEND avcodec_sources eamad.c)
    list(APPEND avcodec_sources eaidct.c)
    list(APPEND avcodec_sources mpeg12.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_EATGQ_DECODER)
    list(APPEND avcodec_sources eatgq.c)
    list(APPEND avcodec_sources eaidct.c)
endif()

if(CONFIG_EATGV_DECODER)
    list(APPEND avcodec_sources eatgv.c)
endif()

if(CONFIG_EATQI_DECODER)
    list(APPEND avcodec_sources eatqi.c)
    list(APPEND avcodec_sources eaidct.c)
    list(APPEND avcodec_sources mpeg12.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_EIGHTBPS_DECODER)
    list(APPEND avcodec_sources 8bps.c)
endif()

if(CONFIG_EIGHTSVX_EXP_DECODER)
    list(APPEND avcodec_sources 8svx.c)
endif()

if(CONFIG_EIGHTSVX_FIB_DECODER)
    list(APPEND avcodec_sources 8svx.c)
endif()

if(CONFIG_ESCAPE124_DECODER)
    list(APPEND avcodec_sources escape124.c)
endif()

if(CONFIG_ESCAPE130_DECODER)
    list(APPEND avcodec_sources escape130.c)
endif()

if(CONFIG_EVRC_DECODER)
    list(APPEND avcodec_sources evrcdec.c)
    list(APPEND avcodec_sources acelp_vectors.c)
    list(APPEND avcodec_sources lsp.c)
endif()

if(CONFIG_EXR_DECODER)
    list(APPEND avcodec_sources exr.c)
    list(APPEND avcodec_sources exrdsp.c)
endif()

if(CONFIG_FASTAUDIO_DECODER)
    list(APPEND avcodec_sources fastaudio.c)
endif()

if(CONFIG_FFV1_DECODER)
    list(APPEND avcodec_sources ffv1dec.c)
    list(APPEND avcodec_sources ffv1_parse.c)
    list(APPEND avcodec_sources ffv1.c)
endif()

if(CONFIG_FFWAVESYNTH_DECODER)
    list(APPEND avcodec_sources ffwavesynth.c)
endif()

if(CONFIG_FIC_DECODER)
    list(APPEND avcodec_sources fic.c)
endif()

if(CONFIG_FITS_DECODER)
    list(APPEND avcodec_sources fitsdec.c)
    list(APPEND avcodec_sources fits.c)
endif()

if(CONFIG_FLAC_DECODER)
    list(APPEND avcodec_sources flacdec.c)
    list(APPEND avcodec_sources flacdata.c)
    list(APPEND avcodec_sources flacdsp.c)
    list(APPEND avcodec_sources flac.c)
endif()

if(CONFIG_FLASHSV_DECODER)
    list(APPEND avcodec_sources flashsv.c)
endif()

if(CONFIG_FLASHSV2_DECODER)
    list(APPEND avcodec_sources flashsv.c)
endif()

if(CONFIG_FLIC_DECODER)
    list(APPEND avcodec_sources flicvideo.c)
endif()

if(CONFIG_FLV_DECODER)
    list(APPEND avcodec_sources flvdec.c)
endif()

if(CONFIG_FMVC_DECODER)
    list(APPEND avcodec_sources fmvc.c)
endif()

if(CONFIG_FOURXM_DECODER)
    list(APPEND avcodec_sources 4xm.c)
endif()

if(CONFIG_FRAPS_DECODER)
    list(APPEND avcodec_sources fraps.c)
endif()

if(CONFIG_FRWU_DECODER)
    list(APPEND avcodec_sources frwu.c)
endif()

if(CONFIG_FTR_DECODER)
    list(APPEND avcodec_sources ftr.c)
endif()

if(CONFIG_G2M_DECODER)
    list(APPEND avcodec_sources g2meet.c)
    list(APPEND avcodec_sources elsdec.c)
    list(APPEND avcodec_sources mjpegdec_common.c)
endif()

if(CONFIG_G723_1_DECODER)
    list(APPEND avcodec_sources g723_1dec.c)
    list(APPEND avcodec_sources g723_1.c)
    list(APPEND avcodec_sources acelp_vectors.c)
    list(APPEND avcodec_sources celp_filters.c)
endif()

if(CONFIG_G728_DECODER)
    list(APPEND avcodec_sources g728dec.c)
    list(APPEND avcodec_sources celp_filters.c)
endif()

if(CONFIG_G729_DECODER)
    list(APPEND avcodec_sources g729dec.c)
    list(APPEND avcodec_sources lsp.c)
    list(APPEND avcodec_sources celp_filters.c)
    list(APPEND avcodec_sources acelp_filters.c)
    list(APPEND avcodec_sources acelp_pitch_delay.c)
    list(APPEND avcodec_sources acelp_vectors.c)
    list(APPEND avcodec_sources g729postfilter.c)
endif()

if(CONFIG_GDV_DECODER)
    list(APPEND avcodec_sources gdv.c)
endif()

if(CONFIG_GEM_DECODER)
    list(APPEND avcodec_sources gemdec.c)
endif()

if(CONFIG_GIF_DECODER)
    list(APPEND avcodec_sources gifdec.c)
    list(APPEND avcodec_sources lzw.c)
endif()

if(CONFIG_GREMLIN_DPCM_DECODER)
    list(APPEND avcodec_sources dpcm.c)
endif()

if(CONFIG_GSM_DECODER)
    list(APPEND avcodec_sources gsmdec.c)
    list(APPEND avcodec_sources gsmdec_data.c)
    list(APPEND avcodec_sources msgsmdec.c)
endif()

if(CONFIG_GSM_MS_DECODER)
    list(APPEND avcodec_sources gsmdec.c)
    list(APPEND avcodec_sources gsmdec_data.c)
    list(APPEND avcodec_sources msgsmdec.c)
endif()

if(CONFIG_H261_DECODER)
    list(APPEND avcodec_sources h261dec.c)
    list(APPEND avcodec_sources h261data.c)
    list(APPEND avcodec_sources h261.c)
endif()

if(CONFIG_H263_DECODER)
    list(APPEND avcodec_sources h263dec.c)
    list(APPEND avcodec_sources h263.c)
    list(APPEND avcodec_sources ituh263dec.c)
    list(APPEND avcodec_sources mpeg4video.c)
    list(APPEND avcodec_sources mpeg4videodec.c)
    list(APPEND avcodec_sources h263data.c)
endif()

if(CONFIG_H263I_DECODER)
    list(APPEND avcodec_sources intelh263dec.c)
endif()

if(CONFIG_H263_V4L2M2M_DECODER)
    list(APPEND avcodec_sources v4l2_m2m_dec.c)
endif()

if(CONFIG_H264_DECODER)
    list(APPEND avcodec_sources h264dec.c)
    list(APPEND avcodec_sources h264_cabac.c)
    list(APPEND avcodec_sources h264_cavlc.c)
    list(APPEND avcodec_sources h264_direct.c)
    list(APPEND avcodec_sources h264_loopfilter.c)
    list(APPEND avcodec_sources h264_mb.c)
    list(APPEND avcodec_sources h264_picture.c)
    list(APPEND avcodec_sources h264_refs.c)
    list(APPEND avcodec_sources h264_slice.c)
    list(APPEND avcodec_sources h264data.c)
    list(APPEND avcodec_sources h274.c)
endif()

if(CONFIG_H264_AMF_DECODER)
    list(APPEND avcodec_sources amfdec.c)
endif()

if(CONFIG_H264_CUVID_DECODER)
    list(APPEND avcodec_sources cuviddec.c)
endif()

if(CONFIG_H264_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_H264_MMAL_DECODER)
    list(APPEND avcodec_sources mmaldec.c)
endif()

if(CONFIG_H264_OH_DECODER)
    list(APPEND avcodec_sources ohcodec.c)
    list(APPEND avcodec_sources ohdec.c)
endif()

if(CONFIG_H264_QSV_DECODER)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_H264_RKMPP_DECODER)
    list(APPEND avcodec_sources rkmppdec.c)
endif()

if(CONFIG_H264_V4L2M2M_DECODER)
    list(APPEND avcodec_sources v4l2_m2m_dec.c)
endif()

if(CONFIG_HAP_DECODER)
    list(APPEND avcodec_sources hapdec.c)
    list(APPEND avcodec_sources hap.c)
endif()

if(CONFIG_HCA_DECODER)
    list(APPEND avcodec_sources hcadec.c)
endif()

if(CONFIG_HCOM_DECODER)
    list(APPEND avcodec_sources hcom.c)
endif()

if(CONFIG_HDR_DECODER)
    list(APPEND avcodec_sources hdrdec.c)
endif()

if(CONFIG_HEVC_DECODER)
    list(APPEND avcodec_sources aom_film_grain.c)
    list(APPEND avcodec_sources h274.c)
    list(APPEND avcodec_sources hevc/cabac.c)
    list(APPEND avcodec_sources hevc/data.c)
    list(APPEND avcodec_sources hevc/dsp.c)
    list(APPEND avcodec_sources hevc/filter.c)
    list(APPEND avcodec_sources hevc/hevcdec.c)
    list(APPEND avcodec_sources hevc/mvs.c)
    list(APPEND avcodec_sources hevc/pred.c)
    list(APPEND avcodec_sources hevc/refs.c)
endif()

if(CONFIG_HEVC_AMF_DECODER)
    list(APPEND avcodec_sources amfdec.c)
endif()

if(CONFIG_HEVC_CUVID_DECODER)
    list(APPEND avcodec_sources cuviddec.c)
endif()

if(CONFIG_HEVC_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_HEVC_OH_DECODER)
    list(APPEND avcodec_sources ohcodec.c)
    list(APPEND avcodec_sources ohdec.c)
endif()

if(CONFIG_HEVC_QSV_DECODER)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_HEVC_RKMPP_DECODER)
    list(APPEND avcodec_sources rkmppdec.c)
endif()

if(CONFIG_HEVC_V4L2M2M_DECODER)
    list(APPEND avcodec_sources v4l2_m2m_dec.c)
endif()

if(CONFIG_HNM4_VIDEO_DECODER)
    list(APPEND avcodec_sources hnm4video.c)
endif()

if(CONFIG_HQ_HQA_DECODER)
    list(APPEND avcodec_sources hq_hqa.c)
    list(APPEND avcodec_sources hq_hqadsp.c)
    list(APPEND avcodec_sources hq_common.c)
    list(APPEND avcodec_sources canopus.c)
endif()

if(CONFIG_HQX_DECODER)
    list(APPEND avcodec_sources hqx.c)
    list(APPEND avcodec_sources hqxdsp.c)
    list(APPEND avcodec_sources hq_common.c)
    list(APPEND avcodec_sources canopus.c)
endif()

if(CONFIG_HUFFYUV_DECODER)
    list(APPEND avcodec_sources huffyuv.c)
    list(APPEND avcodec_sources huffyuvdec.c)
endif()

if(CONFIG_HYMT_DECODER)
    list(APPEND avcodec_sources huffyuv.c)
    list(APPEND avcodec_sources huffyuvdec.c)
endif()

if(CONFIG_IDCIN_DECODER)
    list(APPEND avcodec_sources idcinvideo.c)
endif()

if(CONFIG_IDF_DECODER)
    list(APPEND avcodec_sources bintext.c)
    list(APPEND avcodec_sources cga_data.c)
endif()

if(CONFIG_IFF_ILBM_DECODER)
    list(APPEND avcodec_sources iff.c)
endif()

if(CONFIG_ILBC_DECODER)
    list(APPEND avcodec_sources ilbcdec.c)
endif()

if(CONFIG_IMC_DECODER)
    list(APPEND avcodec_sources imc.c)
endif()

if(CONFIG_IMM4_DECODER)
    list(APPEND avcodec_sources imm4.c)
endif()

if(CONFIG_IMM5_DECODER)
    list(APPEND avcodec_sources imm5.c)
endif()

if(CONFIG_INDEO2_DECODER)
    list(APPEND avcodec_sources indeo2.c)
endif()

if(CONFIG_INDEO3_DECODER)
    list(APPEND avcodec_sources indeo3.c)
endif()

if(CONFIG_INDEO4_DECODER)
    list(APPEND avcodec_sources indeo4.c)
    list(APPEND avcodec_sources ivi.c)
endif()

if(CONFIG_INDEO5_DECODER)
    list(APPEND avcodec_sources indeo5.c)
    list(APPEND avcodec_sources ivi.c)
endif()

if(CONFIG_INTERPLAY_ACM_DECODER)
    list(APPEND avcodec_sources interplayacm.c)
endif()

if(CONFIG_INTERPLAY_DPCM_DECODER)
    list(APPEND avcodec_sources dpcm.c)
endif()

if(CONFIG_INTERPLAY_VIDEO_DECODER)
    list(APPEND avcodec_sources interplayvideo.c)
endif()

if(CONFIG_IPU_DECODER)
    list(APPEND avcodec_sources mpeg12dec.c)
    list(APPEND avcodec_sources mpeg12.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_JACOSUB_DECODER)
    list(APPEND avcodec_sources jacosubdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_JPEG2000_DECODER)
    list(APPEND avcodec_sources jpeg2000dec.c)
    list(APPEND avcodec_sources jpeg2000.c)
    list(APPEND avcodec_sources jpeg2000dsp.c)
    list(APPEND avcodec_sources jpeg2000dwt.c)
    list(APPEND avcodec_sources mqcdec.c)
    list(APPEND avcodec_sources mqc.c)
    list(APPEND avcodec_sources jpeg2000htdec.c)
endif()

if(CONFIG_JPEGLS_DECODER)
    list(APPEND avcodec_sources jpeglsdec.c)
    list(APPEND avcodec_sources jpegls.c)
endif()

if(CONFIG_JV_DECODER)
    list(APPEND avcodec_sources jvdec.c)
endif()

if(CONFIG_KGV1_DECODER)
    list(APPEND avcodec_sources kgv1dec.c)
endif()

if(CONFIG_KMVC_DECODER)
    list(APPEND avcodec_sources kmvc.c)
endif()

if(CONFIG_LAGARITH_DECODER)
    list(APPEND avcodec_sources lagarith.c)
    list(APPEND avcodec_sources lagarithrac.c)
endif()

if(CONFIG_LEAD_DECODER)
    list(APPEND avcodec_sources leaddec.c)
    list(APPEND avcodec_sources jpegquanttables.c)
endif()

if(CONFIG_LOCO_DECODER)
    list(APPEND avcodec_sources loco.c)
endif()

if(CONFIG_LSCR_DECODER)
    list(APPEND avcodec_sources lscrdec.c)
    list(APPEND avcodec_sources png.c)
    list(APPEND avcodec_sources pngdec.c)
    list(APPEND avcodec_sources pngdsp.c)
endif()

if(CONFIG_M101_DECODER)
    list(APPEND avcodec_sources m101.c)
endif()

if(CONFIG_MACE3_DECODER)
    list(APPEND avcodec_sources mace.c)
endif()

if(CONFIG_MACE6_DECODER)
    list(APPEND avcodec_sources mace.c)
endif()

if(CONFIG_MAGICYUV_DECODER)
    list(APPEND avcodec_sources magicyuv.c)
endif()

if(CONFIG_MDEC_DECODER)
    list(APPEND avcodec_sources mdec.c)
    list(APPEND avcodec_sources mpeg12.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_MEDIA100_DECODER)
    list(APPEND avcodec_sources mjpegbdec.c)
endif()

if(CONFIG_METASOUND_DECODER)
    list(APPEND avcodec_sources metasound.c)
    list(APPEND avcodec_sources twinvq.c)
endif()

if(CONFIG_MICRODVD_DECODER)
    list(APPEND avcodec_sources microdvddec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_MIMIC_DECODER)
    list(APPEND avcodec_sources mimic.c)
endif()

if(CONFIG_MISC4_DECODER)
    list(APPEND avcodec_sources misc4.c)
endif()

if(CONFIG_MJPEG_DECODER)
    list(APPEND avcodec_sources mjpegdec.c)
    list(APPEND avcodec_sources mjpegdec_common.c)
endif()

if(CONFIG_MJPEG_QSV_DECODER)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_MJPEGB_DECODER)
    list(APPEND avcodec_sources mjpegbdec.c)
endif()

if(CONFIG_MJPEG_CUVID_DECODER)
    list(APPEND avcodec_sources cuviddec.c)
endif()

if(CONFIG_MLP_DECODER)
    list(APPEND avcodec_sources mlpdec.c)
    list(APPEND avcodec_sources mlpdsp.c)
endif()

if(CONFIG_MMVIDEO_DECODER)
    list(APPEND avcodec_sources mmvideo.c)
endif()

if(CONFIG_MOBICLIP_DECODER)
    list(APPEND avcodec_sources mobiclip.c)
endif()

if(CONFIG_MOTIONPIXELS_DECODER)
    list(APPEND avcodec_sources motionpixels.c)
endif()

if(CONFIG_MOVTEXT_DECODER)
    list(APPEND avcodec_sources movtextdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_MP1_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_fixed.c)
endif()

if(CONFIG_MP1FLOAT_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_float.c)
endif()

if(CONFIG_MP2_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_fixed.c)
endif()

if(CONFIG_MP2FLOAT_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_float.c)
endif()

if(CONFIG_MP3_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_fixed.c)
endif()

if(CONFIG_MP3_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_MP3ADU_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_fixed.c)
endif()

if(CONFIG_MP3ADUFLOAT_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_float.c)
endif()

if(CONFIG_MP3FLOAT_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_float.c)
endif()

if(CONFIG_MP3ON4_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_fixed.c)
endif()

if(CONFIG_MP3ON4FLOAT_DECODER)
    list(APPEND avcodec_sources mpegaudiodec_float.c)
endif()

if(CONFIG_MPC7_DECODER)
    list(APPEND avcodec_sources mpc7.c)
    list(APPEND avcodec_sources mpc.c)
endif()

if(CONFIG_MPC8_DECODER)
    list(APPEND avcodec_sources mpc8.c)
    list(APPEND avcodec_sources mpc.c)
endif()

if(CONFIG_MPEGVIDEO_DECODER)
    list(APPEND avcodec_sources mpeg12dec.c)
    list(APPEND avcodec_sources mpeg12.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_MPEG1VIDEO_DECODER)
    list(APPEND avcodec_sources mpeg12dec.c)
    list(APPEND avcodec_sources mpeg12.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_MPEG1_CUVID_DECODER)
    list(APPEND avcodec_sources cuviddec.c)
endif()

if(CONFIG_MPEG1_V4L2M2M_DECODER)
    list(APPEND avcodec_sources v4l2_m2m_dec.c)
endif()

if(CONFIG_MPEG2_MMAL_DECODER)
    list(APPEND avcodec_sources mmaldec.c)
endif()

if(CONFIG_MPEG2_QSV_DECODER)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_MPEG2VIDEO_DECODER)
    list(APPEND avcodec_sources mpeg12dec.c)
    list(APPEND avcodec_sources mpeg12.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_MPEG2_CUVID_DECODER)
    list(APPEND avcodec_sources cuviddec.c)
endif()

if(CONFIG_MPEG2_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_MPEG2_V4L2M2M_DECODER)
    list(APPEND avcodec_sources v4l2_m2m_dec.c)
endif()

if(CONFIG_MPEG4_DECODER)
    list(APPEND avcodec_sources mpeg4videodec.c)
    list(APPEND avcodec_sources mpeg4videodsp.c)
    list(APPEND avcodec_sources xvididct.c)
endif()

if(CONFIG_MPEG4_CUVID_DECODER)
    list(APPEND avcodec_sources cuviddec.c)
endif()

if(CONFIG_MPEG4_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_MPEG4_V4L2M2M_DECODER)
    list(APPEND avcodec_sources v4l2_m2m_dec.c)
endif()

if(CONFIG_MPL2_DECODER)
    list(APPEND avcodec_sources mpl2dec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_MSA1_DECODER)
    list(APPEND avcodec_sources mss3.c)
endif()

if(CONFIG_MSCC_DECODER)
    list(APPEND avcodec_sources mscc.c)
endif()

if(CONFIG_MSNSIREN_DECODER)
    list(APPEND avcodec_sources siren.c)
endif()

if(CONFIG_MSP2_DECODER)
    list(APPEND avcodec_sources msp2dec.c)
endif()

if(CONFIG_MSRLE_DECODER)
    list(APPEND avcodec_sources msrle.c)
    list(APPEND avcodec_sources msrledec.c)
endif()

if(CONFIG_MSS1_DECODER)
    list(APPEND avcodec_sources mss1.c)
    list(APPEND avcodec_sources mss12.c)
endif()

if(CONFIG_MSS2_DECODER)
    list(APPEND avcodec_sources mss2.c)
    list(APPEND avcodec_sources mss12.c)
    list(APPEND avcodec_sources mss2dsp.c)
    list(APPEND avcodec_sources wmv2data.c)
endif()

if(CONFIG_MSVIDEO1_DECODER)
    list(APPEND avcodec_sources msvideo1.c)
endif()

if(CONFIG_MSZH_DECODER)
    list(APPEND avcodec_sources lcldec.c)
endif()

if(CONFIG_MTS2_DECODER)
    list(APPEND avcodec_sources mss4.c)
endif()

if(CONFIG_MV30_DECODER)
    list(APPEND avcodec_sources mv30.c)
endif()

if(CONFIG_MVC1_DECODER)
    list(APPEND avcodec_sources mvcdec.c)
endif()

if(CONFIG_MVC2_DECODER)
    list(APPEND avcodec_sources mvcdec.c)
endif()

if(CONFIG_MVDV_DECODER)
    list(APPEND avcodec_sources midivid.c)
endif()

if(CONFIG_MVHA_DECODER)
    list(APPEND avcodec_sources mvha.c)
endif()

if(CONFIG_MWSC_DECODER)
    list(APPEND avcodec_sources mwsc.c)
endif()

if(CONFIG_MXPEG_DECODER)
    list(APPEND avcodec_sources mxpegdec.c)
endif()

if(CONFIG_NELLYMOSER_DECODER)
    list(APPEND avcodec_sources nellymoserdec.c)
    list(APPEND avcodec_sources nellymoser.c)
endif()

if(CONFIG_NOTCHLC_DECODER)
    list(APPEND avcodec_sources notchlc.c)
endif()

if(CONFIG_NUV_DECODER)
    list(APPEND avcodec_sources nuv.c)
    list(APPEND avcodec_sources rtjpeg.c)
    list(APPEND avcodec_sources jpegquanttables.c)
endif()

if(CONFIG_ON2AVC_DECODER)
    list(APPEND avcodec_sources on2avc.c)
    list(APPEND avcodec_sources on2avcdata.c)
endif()

if(CONFIG_OPUS_DECODER)
    list(APPEND avcodec_sources vorbis_data.c)
    list(APPEND avcodec_sources opus/dec.c)
    list(APPEND avcodec_sources opus/dec_celt.c)
    list(APPEND avcodec_sources opus/celt.c)
    list(APPEND avcodec_sources opus/frame_duration_tab.c)
    list(APPEND avcodec_sources opus/pvq.c)
    list(APPEND avcodec_sources opus/silk.c)
    list(APPEND avcodec_sources opus/tab.c)
    list(APPEND avcodec_sources opus/dsp.c)
    list(APPEND avcodec_sources opus/parse.c)
    list(APPEND avcodec_sources opus/rc.c)
endif()

if(CONFIG_OSQ_DECODER)
    list(APPEND avcodec_sources osq.c)
endif()

if(CONFIG_PAF_AUDIO_DECODER)
    list(APPEND avcodec_sources pafaudio.c)
endif()

if(CONFIG_PAF_VIDEO_DECODER)
    list(APPEND avcodec_sources pafvideo.c)
endif()

if(CONFIG_PAM_DECODER)
    list(APPEND avcodec_sources pnmdec.c)
    list(APPEND avcodec_sources pnm.c)
endif()

if(CONFIG_PBM_DECODER)
    list(APPEND avcodec_sources pnmdec.c)
    list(APPEND avcodec_sources pnm.c)
endif()

if(CONFIG_PCX_DECODER)
    list(APPEND avcodec_sources pcx.c)
endif()

if(CONFIG_PDV_DECODER)
    list(APPEND avcodec_sources pdvdec.c)
endif()

if(CONFIG_PFM_DECODER)
    list(APPEND avcodec_sources pnmdec.c)
    list(APPEND avcodec_sources pnm.c)
endif()

if(CONFIG_PGM_DECODER)
    list(APPEND avcodec_sources pnmdec.c)
    list(APPEND avcodec_sources pnm.c)
endif()

if(CONFIG_PGMYUV_DECODER)
    list(APPEND avcodec_sources pnmdec.c)
    list(APPEND avcodec_sources pnm.c)
endif()

if(CONFIG_PGSSUB_DECODER)
    list(APPEND avcodec_sources pgssubdec.c)
endif()

if(CONFIG_PGX_DECODER)
    list(APPEND avcodec_sources pgxdec.c)
endif()

if(CONFIG_PHM_DECODER)
    list(APPEND avcodec_sources pnmdec.c)
    list(APPEND avcodec_sources pnm.c)
endif()

if(CONFIG_PHOTOCD_DECODER)
    list(APPEND avcodec_sources photocd.c)
endif()

if(CONFIG_PICTOR_DECODER)
    list(APPEND avcodec_sources pictordec.c)
    list(APPEND avcodec_sources cga_data.c)
endif()

if(CONFIG_PIXLET_DECODER)
    list(APPEND avcodec_sources pixlet.c)
endif()

if(CONFIG_PJS_DECODER)
    list(APPEND avcodec_sources textdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_PNG_DECODER)
    list(APPEND avcodec_sources png.c)
    list(APPEND avcodec_sources pngdec.c)
    list(APPEND avcodec_sources pngdsp.c)
endif()

if(CONFIG_PPM_DECODER)
    list(APPEND avcodec_sources pnmdec.c)
    list(APPEND avcodec_sources pnm.c)
endif()

if(CONFIG_PRORES_DECODER)
    list(APPEND avcodec_sources proresdec.c)
    list(APPEND avcodec_sources proresdsp.c)
    list(APPEND avcodec_sources proresdata.c)
endif()

if(CONFIG_PRORES_RAW_DECODER)
    list(APPEND avcodec_sources prores_raw.c)
    list(APPEND avcodec_sources proresdsp.c)
    list(APPEND avcodec_sources proresdata.c)
endif()

if(CONFIG_PROSUMER_DECODER)
    list(APPEND avcodec_sources prosumer.c)
endif()

if(CONFIG_PSD_DECODER)
    list(APPEND avcodec_sources psd.c)
endif()

if(CONFIG_PTX_DECODER)
    list(APPEND avcodec_sources ptx.c)
endif()

if(CONFIG_QCELP_DECODER)
    list(APPEND avcodec_sources qcelpdec.c)
    list(APPEND avcodec_sources celp_filters.c)
    list(APPEND avcodec_sources acelp_vectors.c)
    list(APPEND avcodec_sources acelp_filters.c)
endif()

if(CONFIG_QDM2_DECODER)
    list(APPEND avcodec_sources qdm2.c)
endif()

if(CONFIG_QDMC_DECODER)
    list(APPEND avcodec_sources qdmc.c)
endif()

if(CONFIG_QDRAW_DECODER)
    list(APPEND avcodec_sources qdrw.c)
endif()

if(CONFIG_QOA_DECODER)
    list(APPEND avcodec_sources qoadec.c)
endif()

if(CONFIG_QOI_DECODER)
    list(APPEND avcodec_sources qoidec.c)
endif()

if(CONFIG_QPEG_DECODER)
    list(APPEND avcodec_sources qpeg.c)
endif()

if(CONFIG_QTRLE_DECODER)
    list(APPEND avcodec_sources qtrle.c)
endif()

if(CONFIG_R10K_DECODER)
    list(APPEND avcodec_sources r210dec.c)
endif()

if(CONFIG_R210_DECODER)
    list(APPEND avcodec_sources r210dec.c)
endif()

if(CONFIG_RA_144_DECODER)
    list(APPEND avcodec_sources ra144dec.c)
    list(APPEND avcodec_sources ra144.c)
    list(APPEND avcodec_sources celp_filters.c)
endif()

if(CONFIG_RA_288_DECODER)
    list(APPEND avcodec_sources ra288.c)
    list(APPEND avcodec_sources celp_filters.c)
endif()

if(CONFIG_RALF_DECODER)
    list(APPEND avcodec_sources ralf.c)
endif()

if(CONFIG_RASC_DECODER)
    list(APPEND avcodec_sources rasc.c)
endif()

if(CONFIG_RAWVIDEO_DECODER)
    list(APPEND avcodec_sources rawdec.c)
endif()

if(CONFIG_REALTEXT_DECODER)
    list(APPEND avcodec_sources realtextdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_RKA_DECODER)
    list(APPEND avcodec_sources rka.c)
endif()

if(CONFIG_RL2_DECODER)
    list(APPEND avcodec_sources rl2.c)
endif()

if(CONFIG_ROQ_DECODER)
    list(APPEND avcodec_sources roqvideodec.c)
    list(APPEND avcodec_sources roqvideo.c)
endif()

if(CONFIG_ROQ_DPCM_DECODER)
    list(APPEND avcodec_sources dpcm.c)
endif()

if(CONFIG_RPZA_DECODER)
    list(APPEND avcodec_sources rpza.c)
endif()

if(CONFIG_RSCC_DECODER)
    list(APPEND avcodec_sources rscc.c)
endif()

if(CONFIG_RTV1_DECODER)
    list(APPEND avcodec_sources rtv1.c)
endif()

if(CONFIG_RV10_DECODER)
    list(APPEND avcodec_sources rv10.c)
endif()

if(CONFIG_RV20_DECODER)
    list(APPEND avcodec_sources rv10.c)
endif()

if(CONFIG_RV30_DECODER)
    list(APPEND avcodec_sources rv30.c)
    list(APPEND avcodec_sources rv34.c)
    list(APPEND avcodec_sources rv30dsp.c)
endif()

if(CONFIG_RV40_DECODER)
    list(APPEND avcodec_sources rv40.c)
    list(APPEND avcodec_sources rv34.c)
    list(APPEND avcodec_sources rv40dsp.c)
endif()

if(CONFIG_RV60_DECODER)
    list(APPEND avcodec_sources rv60dec.c)
    list(APPEND avcodec_sources rv60dsp.c)
endif()

if(CONFIG_SAMI_DECODER)
    list(APPEND avcodec_sources samidec.c)
    list(APPEND avcodec_sources ass.c)
    list(APPEND avcodec_sources htmlsubtitles.c)
endif()

if(CONFIG_S302M_DECODER)
    list(APPEND avcodec_sources s302m.c)
endif()

if(CONFIG_SANM_DECODER)
    list(APPEND avcodec_sources sanm.c)
endif()

if(CONFIG_SCPR_DECODER)
    list(APPEND avcodec_sources scpr.c)
endif()

if(CONFIG_SCREENPRESSO_DECODER)
    list(APPEND avcodec_sources screenpresso.c)
endif()

if(CONFIG_SDX2_DPCM_DECODER)
    list(APPEND avcodec_sources dpcm.c)
endif()

if(CONFIG_SGA_DECODER)
    list(APPEND avcodec_sources sga.c)
endif()

if(CONFIG_SGI_DECODER)
    list(APPEND avcodec_sources sgidec.c)
endif()

if(CONFIG_SGIRLE_DECODER)
    list(APPEND avcodec_sources sgirledec.c)
endif()

if(CONFIG_SHEERVIDEO_DECODER)
    list(APPEND avcodec_sources sheervideo.c)
endif()

if(CONFIG_SHORTEN_DECODER)
    list(APPEND avcodec_sources shorten.c)
endif()

if(CONFIG_SIPR_DECODER)
    list(APPEND avcodec_sources sipr.c)
    list(APPEND avcodec_sources acelp_pitch_delay.c)
    list(APPEND avcodec_sources acelp_vectors.c)
    list(APPEND avcodec_sources acelp_filters.c)
    list(APPEND avcodec_sources celp_filters.c)
    list(APPEND avcodec_sources sipr16k.c)
endif()

if(CONFIG_SIREN_DECODER)
    list(APPEND avcodec_sources siren.c)
endif()

if(CONFIG_SIMBIOSIS_IMX_DECODER)
    list(APPEND avcodec_sources imx.c)
endif()

if(CONFIG_SMACKAUD_DECODER)
    list(APPEND avcodec_sources smacker.c)
endif()

if(CONFIG_SMACKER_DECODER)
    list(APPEND avcodec_sources smacker.c)
endif()

if(CONFIG_SMC_DECODER)
    list(APPEND avcodec_sources smc.c)
endif()

if(CONFIG_SNOW_DECODER)
    list(APPEND avcodec_sources snowdec.c)
    list(APPEND avcodec_sources snow.c)
    list(APPEND avcodec_sources snow_dwt.c)
endif()

if(CONFIG_SOL_DPCM_DECODER)
    list(APPEND avcodec_sources dpcm.c)
endif()

if(CONFIG_SONIC_DECODER)
    list(APPEND avcodec_sources sonic.c)
endif()

if(CONFIG_SPEEDHQ_DECODER)
    list(APPEND avcodec_sources speedhqdec.c)
    list(APPEND avcodec_sources speedhq.c)
    list(APPEND avcodec_sources mpeg12.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_SPEEX_DECODER)
    list(APPEND avcodec_sources speexdec.c)
endif()

if(CONFIG_SP5X_DECODER)
    list(APPEND avcodec_sources sp5xdec.c)
endif()

if(CONFIG_SRGC_DECODER)
    list(APPEND avcodec_sources mscc.c)
endif()

if(CONFIG_SRT_DECODER)
    list(APPEND avcodec_sources srtdec.c)
    list(APPEND avcodec_sources ass.c)
    list(APPEND avcodec_sources htmlsubtitles.c)
endif()

if(CONFIG_STL_DECODER)
    list(APPEND avcodec_sources textdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_SUBRIP_DECODER)
    list(APPEND avcodec_sources srtdec.c)
    list(APPEND avcodec_sources ass.c)
    list(APPEND avcodec_sources htmlsubtitles.c)
endif()

if(CONFIG_SUBVIEWER1_DECODER)
    list(APPEND avcodec_sources textdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_SUBVIEWER_DECODER)
    list(APPEND avcodec_sources subviewerdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_SUNRAST_DECODER)
    list(APPEND avcodec_sources sunrast.c)
endif()

if(CONFIG_SBC_DECODER)
    list(APPEND avcodec_sources sbcdec.c)
    list(APPEND avcodec_sources sbc.c)
endif()

if(CONFIG_SVQ1_DECODER)
    list(APPEND avcodec_sources svq1dec.c)
    list(APPEND avcodec_sources svq1.c)
    list(APPEND avcodec_sources h263data.c)
endif()

if(CONFIG_SVQ3_DECODER)
    list(APPEND avcodec_sources svq3.c)
    list(APPEND avcodec_sources mpegutils.c)
    list(APPEND avcodec_sources h264data.c)
endif()

if(CONFIG_TEXT_DECODER)
    list(APPEND avcodec_sources textdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_TAK_DECODER)
    list(APPEND avcodec_sources takdec.c)
    list(APPEND avcodec_sources tak.c)
    list(APPEND avcodec_sources takdsp.c)
endif()

if(CONFIG_TARGA_DECODER)
    list(APPEND avcodec_sources targa.c)
endif()

if(CONFIG_TARGA_Y216_DECODER)
    list(APPEND avcodec_sources targa_y216dec.c)
endif()

if(CONFIG_TDSC_DECODER)
    list(APPEND avcodec_sources tdsc.c)
endif()

if(CONFIG_TIERTEXSEQVIDEO_DECODER)
    list(APPEND avcodec_sources tiertexseqv.c)
endif()

if(CONFIG_TIFF_DECODER)
    list(APPEND avcodec_sources tiff.c)
    list(APPEND avcodec_sources lzw.c)
    list(APPEND avcodec_sources faxcompr.c)
    list(APPEND avcodec_sources tiff_common.c)
endif()

if(CONFIG_TMV_DECODER)
    list(APPEND avcodec_sources tmv.c)
    list(APPEND avcodec_sources cga_data.c)
endif()

if(CONFIG_TRUEHD_DECODER)
    list(APPEND avcodec_sources mlpdec.c)
    list(APPEND avcodec_sources mlpdsp.c)
endif()

if(CONFIG_TRUEMOTION1_DECODER)
    list(APPEND avcodec_sources truemotion1.c)
endif()

if(CONFIG_TRUEMOTION2_DECODER)
    list(APPEND avcodec_sources truemotion2.c)
endif()

if(CONFIG_TRUEMOTION2RT_DECODER)
    list(APPEND avcodec_sources truemotion2rt.c)
endif()

if(CONFIG_TRUESPEECH_DECODER)
    list(APPEND avcodec_sources truespeech.c)
endif()

if(CONFIG_TSCC_DECODER)
    list(APPEND avcodec_sources tscc.c)
    list(APPEND avcodec_sources msrledec.c)
endif()

if(CONFIG_TSCC2_DECODER)
    list(APPEND avcodec_sources tscc2.c)
endif()

if(CONFIG_TTA_DECODER)
    list(APPEND avcodec_sources tta.c)
    list(APPEND avcodec_sources ttadata.c)
    list(APPEND avcodec_sources ttadsp.c)
endif()

if(CONFIG_TWINVQ_DECODER)
    list(APPEND avcodec_sources twinvqdec.c)
    list(APPEND avcodec_sources twinvq.c)
endif()

if(CONFIG_TXD_DECODER)
    list(APPEND avcodec_sources txd.c)
endif()

if(CONFIG_ULTI_DECODER)
    list(APPEND avcodec_sources ulti.c)
endif()

if(CONFIG_UTVIDEO_DECODER)
    list(APPEND avcodec_sources utvideodec.c)
    list(APPEND avcodec_sources utvideodsp.c)
endif()

if(CONFIG_V210_DECODER)
    list(APPEND avcodec_sources v210dec.c)
endif()

if(CONFIG_V210X_DECODER)
    list(APPEND avcodec_sources v210x.c)
endif()

if(CONFIG_V308_DECODER)
    list(APPEND avcodec_sources v308dec.c)
endif()

if(CONFIG_V408_DECODER)
    list(APPEND avcodec_sources v408dec.c)
endif()

if(CONFIG_V410_DECODER)
    list(APPEND avcodec_sources v410dec.c)
endif()

if(CONFIG_VB_DECODER)
    list(APPEND avcodec_sources vb.c)
endif()

if(CONFIG_VBN_DECODER)
    list(APPEND avcodec_sources vbndec.c)
endif()

if(CONFIG_VBLE_DECODER)
    list(APPEND avcodec_sources vble.c)
endif()

if(CONFIG_VC1_DECODER)
    list(APPEND avcodec_sources vc1dec.c)
    list(APPEND avcodec_sources vc1_block.c)
    list(APPEND avcodec_sources vc1_loopfilter.c)
    list(APPEND avcodec_sources vc1_mc.c)
    list(APPEND avcodec_sources vc1_pred.c)
    list(APPEND avcodec_sources vc1.c)
    list(APPEND avcodec_sources vc1data.c)
    list(APPEND avcodec_sources msmpeg4_vc1_data.c)
    list(APPEND avcodec_sources wmv2data.c)
endif()

if(CONFIG_VC1_CUVID_DECODER)
    list(APPEND avcodec_sources cuviddec.c)
endif()

if(CONFIG_VC1_MMAL_DECODER)
    list(APPEND avcodec_sources mmaldec.c)
endif()

if(CONFIG_VC1_QSV_DECODER)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_VC1_V4L2M2M_DECODER)
    list(APPEND avcodec_sources v4l2_m2m_dec.c)
endif()

if(CONFIG_VCR1_DECODER)
    list(APPEND avcodec_sources vcr1.c)
endif()

if(CONFIG_VMDAUDIO_DECODER)
    list(APPEND avcodec_sources vmdaudio.c)
endif()

if(CONFIG_VMDVIDEO_DECODER)
    list(APPEND avcodec_sources vmdvideo.c)
endif()

if(CONFIG_VMIX_DECODER)
    list(APPEND avcodec_sources vmixdec.c)
endif()

if(CONFIG_VMNC_DECODER)
    list(APPEND avcodec_sources vmnc.c)
endif()

if(CONFIG_VNULL_DECODER)
    list(APPEND avcodec_sources null.c)
endif()

if(CONFIG_VORBIS_DECODER)
    list(APPEND avcodec_sources vorbisdec.c)
    list(APPEND avcodec_sources vorbisdsp.c)
    list(APPEND avcodec_sources vorbis.c)
    list(APPEND avcodec_sources vorbis_data.c)
endif()

if(CONFIG_VP3_DECODER)
    list(APPEND avcodec_sources vp3.c)
    list(APPEND avcodec_sources jpegquanttables.c)
endif()

if(CONFIG_VP5_DECODER)
    list(APPEND avcodec_sources vp5.c)
    list(APPEND avcodec_sources vp56.c)
    list(APPEND avcodec_sources vp56data.c)
    list(APPEND avcodec_sources vp5dsp.c)
    list(APPEND avcodec_sources vpx_rac.c)
endif()

if(CONFIG_VP6_DECODER)
    list(APPEND avcodec_sources vp6.c)
    list(APPEND avcodec_sources vp56.c)
    list(APPEND avcodec_sources vp56data.c)
    list(APPEND avcodec_sources vp6dsp.c)
    list(APPEND avcodec_sources vpx_rac.c)
endif()

if(CONFIG_VP7_DECODER)
    list(APPEND avcodec_sources vp8.c)
    list(APPEND avcodec_sources vp8data.c)
    list(APPEND avcodec_sources vpx_rac.c)
endif()

if(CONFIG_VP8_DECODER)
    list(APPEND avcodec_sources vp8.c)
    list(APPEND avcodec_sources vp8data.c)
    list(APPEND avcodec_sources vpx_rac.c)
endif()

if(CONFIG_VP8_CUVID_DECODER)
    list(APPEND avcodec_sources cuviddec.c)
endif()

if(CONFIG_VP8_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_VP8_QSV_DECODER)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_VP8_RKMPP_DECODER)
    list(APPEND avcodec_sources rkmppdec.c)
endif()

if(CONFIG_VP8_V4L2M2M_DECODER)
    list(APPEND avcodec_sources v4l2_m2m_dec.c)
endif()

if(CONFIG_VP9_DECODER)
    list(APPEND avcodec_sources vp9.c)
    list(APPEND avcodec_sources vp9data.c)
    list(APPEND avcodec_sources vp9dsp.c)
    list(APPEND avcodec_sources vp9lpf.c)
    list(APPEND avcodec_sources vp9recon.c)
    list(APPEND avcodec_sources vp9block.c)
    list(APPEND avcodec_sources vp9prob.c)
    list(APPEND avcodec_sources vp9mvs.c)
    list(APPEND avcodec_sources vpx_rac.c)
    list(APPEND avcodec_sources vp9dsp_8bpp.c)
    list(APPEND avcodec_sources vp9dsp_10bpp.c)
    list(APPEND avcodec_sources vp9dsp_12bpp.c)
endif()

if(CONFIG_VP9_AMF_DECODER)
    list(APPEND avcodec_sources amfdec.c)
endif()

if(CONFIG_VP9_CUVID_DECODER)
    list(APPEND avcodec_sources cuviddec.c)
endif()

if(CONFIG_VP9_MEDIACODEC_DECODER)
    list(APPEND avcodec_sources mediacodecdec.c)
endif()

if(CONFIG_VP9_RKMPP_DECODER)
    list(APPEND avcodec_sources rkmppdec.c)
endif()

if(CONFIG_VPLAYER_DECODER)
    list(APPEND avcodec_sources textdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_VP9_V4L2M2M_DECODER)
    list(APPEND avcodec_sources v4l2_m2m_dec.c)
endif()

if(CONFIG_VQA_DECODER)
    list(APPEND avcodec_sources vqavideo.c)
endif()

if(CONFIG_VQC_DECODER)
    list(APPEND avcodec_sources vqcdec.c)
endif()

if(CONFIG_VVC_DECODER)
    list(APPEND avcodec_sources executor.c)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources vvc/dec.c)
    list(APPEND avcodec_sources vvc/dsp.c)
    list(APPEND avcodec_sources vvc/cabac.c)
    list(APPEND avcodec_sources vvc/ctu.c)
    list(APPEND avcodec_sources vvc/data.c)
    list(APPEND avcodec_sources vvc/filter.c)
    list(APPEND avcodec_sources vvc/inter.c)
    list(APPEND avcodec_sources vvc/intra.c)
    list(APPEND avcodec_sources vvc/intra_utils.c)
    list(APPEND avcodec_sources vvc/itx_1d.c)
    list(APPEND avcodec_sources vvc/mvs.c)
    list(APPEND avcodec_sources vvc/ps.c)
    list(APPEND avcodec_sources vvc/refs.c)
    list(APPEND avcodec_sources vvc/sei.c)
    list(APPEND avcodec_sources vvc/thread.c)
endif()

if(CONFIG_WADY_DPCM_DECODER)
    list(APPEND avcodec_sources dpcm.c)
endif()

if(CONFIG_WAVARC_DECODER)
    list(APPEND avcodec_sources wavarc.c)
endif()

if(CONFIG_WAVPACK_DECODER)
    list(APPEND avcodec_sources wavpack.c)
    list(APPEND avcodec_sources wavpackdata.c)
    list(APPEND avcodec_sources dsd.c)
endif()

if(CONFIG_WBMP_DECODER)
    list(APPEND avcodec_sources wbmpdec.c)
endif()

if(CONFIG_WCMV_DECODER)
    list(APPEND avcodec_sources wcmv.c)
endif()

if(CONFIG_WEBP_DECODER)
    list(APPEND avcodec_sources webp.c)
endif()

if(CONFIG_WEBVTT_DECODER)
    list(APPEND avcodec_sources webvttdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_WMALOSSLESS_DECODER)
    list(APPEND avcodec_sources wmalosslessdec.c)
    list(APPEND avcodec_sources wma_common.c)
endif()

if(CONFIG_WMAPRO_DECODER)
    list(APPEND avcodec_sources wmaprodec.c)
    list(APPEND avcodec_sources wma.c)
    list(APPEND avcodec_sources wma_common.c)
endif()

if(CONFIG_WMAV1_DECODER)
    list(APPEND avcodec_sources wmadec.c)
    list(APPEND avcodec_sources wma.c)
    list(APPEND avcodec_sources wma_common.c)
    list(APPEND avcodec_sources aactab.c)
endif()

if(CONFIG_WMAV2_DECODER)
    list(APPEND avcodec_sources wmadec.c)
    list(APPEND avcodec_sources wma.c)
    list(APPEND avcodec_sources wma_common.c)
    list(APPEND avcodec_sources aactab.c)
endif()

if(CONFIG_WMAVOICE_DECODER)
    list(APPEND avcodec_sources wmavoice.c)
    list(APPEND avcodec_sources celp_filters.c)
    list(APPEND avcodec_sources acelp_vectors.c)
    list(APPEND avcodec_sources acelp_filters.c)
endif()

if(CONFIG_WMV2_DECODER)
    list(APPEND avcodec_sources wmv2dec.c)
    list(APPEND avcodec_sources wmv2data.c)
endif()

if(CONFIG_WNV1_DECODER)
    list(APPEND avcodec_sources wnv1.c)
endif()

if(CONFIG_WRAPPED_AVFRAME_DECODER)
    list(APPEND avcodec_sources wrapped_avframe.c)
endif()

if(CONFIG_WS_SND1_DECODER)
    list(APPEND avcodec_sources ws-snd1.c)
endif()

if(CONFIG_XAN_DPCM_DECODER)
    list(APPEND avcodec_sources dpcm.c)
endif()

if(CONFIG_XAN_WC3_DECODER)
    list(APPEND avcodec_sources xan.c)
endif()

if(CONFIG_XAN_WC4_DECODER)
    list(APPEND avcodec_sources xxan.c)
endif()

if(CONFIG_XBIN_DECODER)
    list(APPEND avcodec_sources bintext.c)
    list(APPEND avcodec_sources cga_data.c)
endif()

if(CONFIG_XBM_DECODER)
    list(APPEND avcodec_sources xbmdec.c)
endif()

if(CONFIG_XFACE_DECODER)
    list(APPEND avcodec_sources xfacedec.c)
    list(APPEND avcodec_sources xface.c)
endif()

if(CONFIG_XL_DECODER)
    list(APPEND avcodec_sources xl.c)
endif()

if(CONFIG_XMA1_DECODER)
    list(APPEND avcodec_sources wmaprodec.c)
    list(APPEND avcodec_sources wma.c)
    list(APPEND avcodec_sources wma_common.c)
endif()

if(CONFIG_XMA2_DECODER)
    list(APPEND avcodec_sources wmaprodec.c)
    list(APPEND avcodec_sources wma.c)
    list(APPEND avcodec_sources wma_common.c)
endif()

if(CONFIG_XPM_DECODER)
    list(APPEND avcodec_sources xpmdec.c)
endif()

if(CONFIG_XSUB_DECODER)
    list(APPEND avcodec_sources xsubdec.c)
endif()

if(CONFIG_XWD_DECODER)
    list(APPEND avcodec_sources xwddec.c)
endif()

if(CONFIG_Y41P_DECODER)
    list(APPEND avcodec_sources y41pdec.c)
endif()

if(CONFIG_YLC_DECODER)
    list(APPEND avcodec_sources ylc.c)
endif()

if(CONFIG_YOP_DECODER)
    list(APPEND avcodec_sources yop.c)
endif()

if(CONFIG_YUV4_DECODER)
    list(APPEND avcodec_sources yuv4dec.c)
endif()

if(CONFIG_ZEROCODEC_DECODER)
    list(APPEND avcodec_sources zerocodec.c)
endif()

if(CONFIG_ZLIB_DECODER)
    list(APPEND avcodec_sources lcldec.c)
endif()

if(CONFIG_ZMBV_DECODER)
    list(APPEND avcodec_sources zmbv.c)
endif()

if(CONFIG_PCM_ALAW_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_BLURAY_DECODER)
    list(APPEND avcodec_sources pcm-bluray.c)
endif()

if(CONFIG_PCM_DVD_DECODER)
    list(APPEND avcodec_sources pcm-dvd.c)
endif()

if(CONFIG_PCM_F16LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_F24LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_F32BE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_F32LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_F64BE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_F64LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_LXF_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_MULAW_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S8_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S8_PLANAR_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S16BE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S16BE_PLANAR_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S16LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S16LE_PLANAR_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S24BE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S24DAUD_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S24LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S24LE_PLANAR_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S32BE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S32LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S32LE_PLANAR_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S64BE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S64LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_SGA_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U8_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U16BE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U16LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U24BE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U24LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U32BE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U32LE_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_VIDC_DECODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_ADPCM_4XM_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_ADX_DECODER)
    list(APPEND avcodec_sources adxdec.c)
    list(APPEND avcodec_sources adx.c)
endif()

if(CONFIG_ADPCM_AFC_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_AGM_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_AICA_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_ARGO_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_CIRCUS_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_CT_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_DTK_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_EA_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_EA_MAXIS_XA_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_EA_R1_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_EA_R2_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_EA_R3_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_EA_XAS_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_G722_DECODER)
    list(APPEND avcodec_sources g722.c)
    list(APPEND avcodec_sources g722dsp.c)
    list(APPEND avcodec_sources g722dec.c)
endif()

if(CONFIG_ADPCM_G726_DECODER)
    list(APPEND avcodec_sources g726.c)
endif()

if(CONFIG_ADPCM_G726LE_DECODER)
    list(APPEND avcodec_sources g726.c)
endif()

if(CONFIG_ADPCM_IMA_ACORN_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_AMV_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_ALP_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_APC_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_APM_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_CUNNING_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_DAT4_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_DK3_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_DK4_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_EA_EACS_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_EA_SEAD_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_ESCAPE_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_HVQM2_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_HVQM4_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_ISS_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_MAGIX_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_MOFLEX_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_MTF_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_PDA_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_OKI_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_QT_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_RAD_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_SSI_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_SMJPEG_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_WAV_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_WS_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_XBOX_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_MS_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_MTAF_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_N64_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_PSX_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_PSXC_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_SANYO_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_SBPRO_2_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_SBPRO_3_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_SBPRO_4_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_SWF_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_THP_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_THP_LE_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_VIMA_DECODER)
    list(APPEND avcodec_sources vima.c)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_XA_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_XMD_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_YAMAHA_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_ZORK_DECODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_AAC_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_AC3_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_ADPCM_IMA_QT_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_ALAC_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_AMR_NB_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_EAC3_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_GSM_MS_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_ILBC_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_MP1_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_MP2_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_MP3_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_PCM_MULAW_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_PCM_ALAW_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_QDMC_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_QDM2_AT_DECODER)
    list(APPEND avcodec_sources audiotoolboxdec.c)
endif()

if(CONFIG_LIBAOM_AV1_DECODER)
    list(APPEND avcodec_sources libaomdec.c)
    list(APPEND avcodec_sources libaom.c)
endif()

if(CONFIG_LIBARIBB24_DECODER)
    list(APPEND avcodec_sources libaribb24.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_LIBARIBCAPTION_DECODER)
    list(APPEND avcodec_sources libaribcaption.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_LIBCELT_DECODER)
    list(APPEND avcodec_sources libcelt_dec.c)
endif()

if(CONFIG_LIBCODEC2_DECODER)
    list(APPEND avcodec_sources libcodec2.c)
endif()

if(CONFIG_LIBDAV1D_DECODER)
    list(APPEND avcodec_sources libdav1d.c)
    list(APPEND avcodec_sources av1_parse.c)
endif()

if(CONFIG_LIBDAVS2_DECODER)
    list(APPEND avcodec_sources libdavs2.c)
endif()

if(CONFIG_LIBFDK_AAC_DECODER)
    list(APPEND avcodec_sources libfdk-aacdec.c)
endif()

if(CONFIG_LIBGSM_DECODER)
    list(APPEND avcodec_sources libgsmdec.c)
endif()

if(CONFIG_LIBGSM_MS_DECODER)
    list(APPEND avcodec_sources libgsmdec.c)
endif()

if(CONFIG_LIBILBC_DECODER)
    list(APPEND avcodec_sources libilbc.c)
endif()

if(CONFIG_LIBJXL_DECODER)
    list(APPEND avcodec_sources libjxldec.c)
    list(APPEND avcodec_sources libjxl.c)
endif()

if(CONFIG_LIBLC3_DECODER)
    list(APPEND avcodec_sources liblc3dec.c)
endif()

if(CONFIG_LIBMPEGHDEC_DECODER)
    list(APPEND avcodec_sources libmpeghdec.c)
endif()

if(CONFIG_LIBOPENCORE_AMRNB_DECODER)
    list(APPEND avcodec_sources libopencore-amr.c)
endif()

if(CONFIG_LIBOPENCORE_AMRWB_DECODER)
    list(APPEND avcodec_sources libopencore-amr.c)
endif()

if(CONFIG_LIBOPENH264_DECODER)
    list(APPEND avcodec_sources libopenh264dec.c)
    list(APPEND avcodec_sources libopenh264.c)
endif()

if(CONFIG_LIBOPUS_DECODER)
    list(APPEND avcodec_sources libopusdec.c)
    list(APPEND avcodec_sources libopus.c)
    list(APPEND avcodec_sources vorbis_data.c)
endif()

if(CONFIG_LIBRSVG_DECODER)
    list(APPEND avcodec_sources librsvgdec.c)
endif()

if(CONFIG_LIBSPEEX_DECODER)
    list(APPEND avcodec_sources libspeexdec.c)
endif()

if(CONFIG_LIBSVTJPEGXS_DECODER)
    list(APPEND avcodec_sources libsvtjpegxsdec.c)
endif()

if(CONFIG_LIBUAVS3D_DECODER)
    list(APPEND avcodec_sources libuavs3d.c)
endif()

if(CONFIG_LIBVORBIS_DECODER)
    list(APPEND avcodec_sources libvorbisdec.c)
endif()

if(CONFIG_LIBVPX_VP8_DECODER)
    list(APPEND avcodec_sources libvpxdec.c)
endif()

if(CONFIG_LIBVPX_VP9_DECODER)
    list(APPEND avcodec_sources libvpxdec.c)
endif()

if(CONFIG_LIBXEVD_DECODER)
    list(APPEND avcodec_sources libxevd.c)
endif()

if(CONFIG_LIBZVBI_TELETEXT_DECODER)
    list(APPEND avcodec_sources libzvbi-teletextdec.c)
    list(APPEND avcodec_sources ass.c)
endif()

# ============================================================================
# Encoder sources (CONFIG_*_ENCODER)
# ============================================================================

if(CONFIG_AV1_AMF_ENCODER)
    list(APPEND avcodec_sources amfenc_av1.c)
endif()

if(CONFIG_A64MULTI_ENCODER)
    list(APPEND avcodec_sources a64multienc.c)
    list(APPEND avcodec_sources elbg.c)
endif()

if(CONFIG_A64MULTI5_ENCODER)
    list(APPEND avcodec_sources a64multienc.c)
    list(APPEND avcodec_sources elbg.c)
endif()

if(CONFIG_AAC_ENCODER)
    list(APPEND avcodec_sources aacenc.c)
    list(APPEND avcodec_sources aaccoder.c)
    list(APPEND avcodec_sources aacenctab.c)
    list(APPEND avcodec_sources aacpsy.c)
    list(APPEND avcodec_sources aactab.c)
    list(APPEND avcodec_sources aacenc_is.c)
    list(APPEND avcodec_sources aacenc_tns.c)
    list(APPEND avcodec_sources psymodel.c)
    list(APPEND avcodec_sources kbdwin.c)
    list(APPEND avcodec_sources mpeg4audio_sample_rates.c)
endif()

if(CONFIG_AAC_MF_ENCODER)
    list(APPEND avcodec_sources mfenc.c)
    list(APPEND avcodec_sources mf_utils.c)
endif()

if(CONFIG_AC3_ENCODER)
    list(APPEND avcodec_sources ac3enc_float.c)
    list(APPEND avcodec_sources ac3enc.c)
    list(APPEND avcodec_sources ac3tab.c)
    list(APPEND avcodec_sources ac3.c)
    list(APPEND avcodec_sources kbdwin.c)
endif()

if(CONFIG_AC3_FIXED_ENCODER)
    list(APPEND avcodec_sources ac3enc_fixed.c)
    list(APPEND avcodec_sources ac3enc.c)
    list(APPEND avcodec_sources ac3tab.c)
    list(APPEND avcodec_sources ac3.c)
    list(APPEND avcodec_sources kbdwin.c)
endif()

if(CONFIG_AC3_MF_ENCODER)
    list(APPEND avcodec_sources mfenc.c)
    list(APPEND avcodec_sources mf_utils.c)
endif()

if(CONFIG_ALAC_ENCODER)
    list(APPEND avcodec_sources alacenc.c)
    list(APPEND avcodec_sources alac_data.c)
endif()

if(CONFIG_ALIAS_PIX_ENCODER)
    list(APPEND avcodec_sources aliaspixenc.c)
endif()

if(CONFIG_AMV_ENCODER)
    list(APPEND avcodec_sources mjpegenc.c)
    list(APPEND avcodec_sources mjpegenc_common.c)
endif()

if(CONFIG_ANULL_ENCODER)
    list(APPEND avcodec_sources null.c)
endif()

if(CONFIG_APTX_ENCODER)
    list(APPEND avcodec_sources aptxenc.c)
    list(APPEND avcodec_sources aptx.c)
endif()

if(CONFIG_APTX_HD_ENCODER)
    list(APPEND avcodec_sources aptxenc.c)
    list(APPEND avcodec_sources aptx.c)
endif()

if(CONFIG_APNG_ENCODER)
    list(APPEND avcodec_sources png.c)
    list(APPEND avcodec_sources pngenc.c)
endif()

if(CONFIG_SSA_ENCODER)
    list(APPEND avcodec_sources assenc.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_ASS_ENCODER)
    list(APPEND avcodec_sources assenc.c)
    list(APPEND avcodec_sources ass.c)
endif()

if(CONFIG_ASV1_ENCODER)
    list(APPEND avcodec_sources asvenc.c)
    list(APPEND avcodec_sources asv.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_ASV2_ENCODER)
    list(APPEND avcodec_sources asvenc.c)
    list(APPEND avcodec_sources asv.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_AV1_D3D12VA_ENCODER)
    list(APPEND avcodec_sources d3d12va_encode_av1.c)
    list(APPEND avcodec_sources av1_levels.c)
endif()

if(CONFIG_AV1_MEDIACODEC_ENCODER)
    list(APPEND avcodec_sources mediacodecenc.c)
endif()

if(CONFIG_AV1_NVENC_ENCODER)
    list(APPEND avcodec_sources nvenc_av1.c)
    list(APPEND avcodec_sources nvenc.c)
endif()

if(CONFIG_AV1_QSV_ENCODER)
    list(APPEND avcodec_sources qsvenc_av1.c)
endif()

if(CONFIG_AV1_VAAPI_ENCODER)
    list(APPEND avcodec_sources vaapi_encode_av1.c)
    list(APPEND avcodec_sources av1_levels.c)
endif()

if(CONFIG_AV1_VULKAN_ENCODER)
    list(APPEND avcodec_sources vulkan_encode.c)
    list(APPEND avcodec_sources vulkan_encode_av1.c)
    list(APPEND avcodec_sources hw_base_encode.c)
    list(APPEND avcodec_sources av1_levels.c)
endif()

if(CONFIG_AVRP_ENCODER)
    list(APPEND avcodec_sources r210enc.c)
endif()

if(CONFIG_AVUI_ENCODER)
    list(APPEND avcodec_sources avuienc.c)
endif()

if(CONFIG_BITPACKED_ENCODER)
    list(APPEND avcodec_sources bitpacked_enc.c)
endif()

if(CONFIG_BMP_ENCODER)
    list(APPEND avcodec_sources bmpenc.c)
endif()

if(CONFIG_CFHD_ENCODER)
    list(APPEND avcodec_sources cfhdenc.c)
    list(APPEND avcodec_sources cfhddata.c)
    list(APPEND avcodec_sources cfhdencdsp.c)
endif()

if(CONFIG_CINEPAK_ENCODER)
    list(APPEND avcodec_sources cinepakenc.c)
    list(APPEND avcodec_sources elbg.c)
endif()

if(CONFIG_CLJR_ENCODER)
    list(APPEND avcodec_sources cljrenc.c)
endif()

if(CONFIG_COMFORTNOISE_ENCODER)
    list(APPEND avcodec_sources cngenc.c)
endif()

if(CONFIG_DCA_ENCODER)
    list(APPEND avcodec_sources dcaenc.c)
    list(APPEND avcodec_sources dcadata.c)
    list(APPEND avcodec_sources dcahuff.c)
    list(APPEND avcodec_sources dcaadpcm.c)
endif()

if(CONFIG_DFPWM_ENCODER)
    list(APPEND avcodec_sources dfpwmenc.c)
endif()

if(CONFIG_DNXHD_ENCODER)
    list(APPEND avcodec_sources dnxhdenc.c)
    list(APPEND avcodec_sources dnxhddata.c)
endif()

if(CONFIG_DPX_ENCODER)
    list(APPEND avcodec_sources dpxenc.c)
endif()

if(CONFIG_DVBSUB_ENCODER)
    list(APPEND avcodec_sources dvbsubenc.c)
endif()

if(CONFIG_DVDSUB_ENCODER)
    list(APPEND avcodec_sources dvdsubenc.c)
    list(APPEND avcodec_sources dvdsub.c)
endif()

if(CONFIG_DVVIDEO_ENCODER)
    list(APPEND avcodec_sources dvenc.c)
    list(APPEND avcodec_sources dv.c)
    list(APPEND avcodec_sources dvdata.c)
endif()

if(CONFIG_DXV_ENCODER)
    list(APPEND avcodec_sources dxvenc.c)
    list(APPEND avcodec_sources hashtable.c)
endif()

if(CONFIG_EAC3_ENCODER)
    list(APPEND avcodec_sources eac3enc.c)
    list(APPEND avcodec_sources eac3_data.c)
endif()

if(CONFIG_EXR_ENCODER)
    list(APPEND avcodec_sources exrenc.c)
endif()

if(CONFIG_FFV1_ENCODER)
    list(APPEND avcodec_sources ffv1enc.c)
    list(APPEND avcodec_sources ffv1_parse.c)
    list(APPEND avcodec_sources ffv1.c)
endif()

if(CONFIG_FFV1_VULKAN_ENCODER)
    list(APPEND avcodec_sources ffv1enc.c)
    list(APPEND avcodec_sources ffv1.c)
    list(APPEND avcodec_sources ffv1_vulkan.c)
    list(APPEND avcodec_sources ffv1enc_vulkan.c)
endif()

if(CONFIG_FITS_ENCODER)
    list(APPEND avcodec_sources fitsenc.c)
endif()

if(CONFIG_FLAC_ENCODER)
    list(APPEND avcodec_sources flacenc.c)
    list(APPEND avcodec_sources flacdata.c)
    list(APPEND avcodec_sources flacencdsp.c)
endif()

if(CONFIG_FLASHSV_ENCODER)
    list(APPEND avcodec_sources flashsvenc.c)
endif()

if(CONFIG_FLASHSV2_ENCODER)
    list(APPEND avcodec_sources flashsv2enc.c)
endif()

if(CONFIG_FLV_ENCODER)
    list(APPEND avcodec_sources flvenc.c)
endif()

if(CONFIG_G723_1_ENCODER)
    list(APPEND avcodec_sources g723_1enc.c)
    list(APPEND avcodec_sources g723_1.c)
    list(APPEND avcodec_sources acelp_vectors.c)
    list(APPEND avcodec_sources celp_filters.c)
endif()

if(CONFIG_GIF_ENCODER)
    list(APPEND avcodec_sources gif.c)
    list(APPEND avcodec_sources lzwenc.c)
endif()

if(CONFIG_H261_ENCODER)
    list(APPEND avcodec_sources h261enc.c)
    list(APPEND avcodec_sources h261data.c)
    list(APPEND avcodec_sources h261.c)
endif()

if(CONFIG_H263_ENCODER)
    list(APPEND avcodec_sources mpeg4video.c)
    list(APPEND avcodec_sources h263.c)
    list(APPEND avcodec_sources ituh263enc.c)
    list(APPEND avcodec_sources h263data.c)
endif()

if(CONFIG_H263_V4L2M2M_ENCODER)
    list(APPEND avcodec_sources v4l2_m2m_enc.c)
endif()

if(CONFIG_H264_AMF_ENCODER)
    list(APPEND avcodec_sources amfenc_h264.c)
endif()

if(CONFIG_H264_D3D12VA_ENCODER)
    list(APPEND avcodec_sources d3d12va_encode_h264.c)
    list(APPEND avcodec_sources h264_levels.c)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources hw_base_encode_h264.c)
endif()

if(CONFIG_H264_MEDIACODEC_ENCODER)
    list(APPEND avcodec_sources mediacodecenc.c)
endif()

if(CONFIG_H264_MF_ENCODER)
    list(APPEND avcodec_sources mfenc.c)
    list(APPEND avcodec_sources mf_utils.c)
endif()

if(CONFIG_H264_NVENC_ENCODER)
    list(APPEND avcodec_sources nvenc_h264.c)
    list(APPEND avcodec_sources nvenc.c)
endif()

if(CONFIG_H264_OH_ENCODER)
    list(APPEND avcodec_sources ohcodec.c)
    list(APPEND avcodec_sources ohenc.c)
endif()

if(CONFIG_H264_OMX_ENCODER)
    list(APPEND avcodec_sources omx.c)
endif()

if(CONFIG_H264_QSV_ENCODER)
    list(APPEND avcodec_sources qsvenc_h264.c)
endif()

if(CONFIG_H264_RKMPP_ENCODER)
    list(APPEND avcodec_sources rkmppenc.c)
endif()

if(CONFIG_H264_VAAPI_ENCODER)
    list(APPEND avcodec_sources vaapi_encode_h264.c)
    list(APPEND avcodec_sources h264_levels.c)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources hw_base_encode_h264.c)
endif()

if(CONFIG_H264_VULKAN_ENCODER)
    list(APPEND avcodec_sources vulkan_encode.c)
    list(APPEND avcodec_sources vulkan_encode_h264.c)
    list(APPEND avcodec_sources hw_base_encode.c)
    list(APPEND avcodec_sources hw_base_encode_h264.c)
    list(APPEND avcodec_sources h264_levels.c)
    list(APPEND avcodec_sources h2645data.c)
endif()

if(CONFIG_H264_VIDEOTOOLBOX_ENCODER)
    list(APPEND avcodec_sources videotoolboxenc.c)
endif()

if(CONFIG_H264_V4L2M2M_ENCODER)
    list(APPEND avcodec_sources v4l2_m2m_enc.c)
endif()

if(CONFIG_HAP_ENCODER)
    list(APPEND avcodec_sources hapenc.c)
    list(APPEND avcodec_sources hap.c)
endif()

if(CONFIG_HDR_ENCODER)
    list(APPEND avcodec_sources hdrenc.c)
endif()

if(CONFIG_HEVC_AMF_ENCODER)
    list(APPEND avcodec_sources amfenc_hevc.c)
endif()

if(CONFIG_HEVC_D3D12VA_ENCODER)
    list(APPEND avcodec_sources d3d12va_encode_hevc.c)
    list(APPEND avcodec_sources h265_profile_level.c)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources hw_base_encode_h265.c)
endif()

if(CONFIG_HEVC_MEDIACODEC_ENCODER)
    list(APPEND avcodec_sources mediacodecenc.c)
endif()

if(CONFIG_HEVC_MF_ENCODER)
    list(APPEND avcodec_sources mfenc.c)
    list(APPEND avcodec_sources mf_utils.c)
endif()

if(CONFIG_HEVC_NVENC_ENCODER)
    list(APPEND avcodec_sources nvenc_hevc.c)
    list(APPEND avcodec_sources nvenc.c)
endif()

if(CONFIG_HEVC_OH_ENCODER)
    list(APPEND avcodec_sources ohcodec.c)
    list(APPEND avcodec_sources ohenc.c)
endif()

if(CONFIG_HEVC_QSV_ENCODER)
    list(APPEND avcodec_sources qsvenc_hevc.c)
    list(APPEND avcodec_sources hevc/ps_enc.c)
endif()

if(CONFIG_HEVC_RKMPP_ENCODER)
    list(APPEND avcodec_sources rkmppenc.c)
endif()

if(CONFIG_HEVC_VAAPI_ENCODER)
    list(APPEND avcodec_sources vaapi_encode_h265.c)
    list(APPEND avcodec_sources h265_profile_level.c)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources hw_base_encode_h265.c)
endif()

if(CONFIG_HEVC_VULKAN_ENCODER)
    list(APPEND avcodec_sources vulkan_encode.c)
    list(APPEND avcodec_sources vulkan_encode_h265.c)
    list(APPEND avcodec_sources hw_base_encode.c)
    list(APPEND avcodec_sources hw_base_encode_h265.c)
    list(APPEND avcodec_sources h265_profile_level.c)
    list(APPEND avcodec_sources h2645data.c)
endif()

if(CONFIG_HEVC_V4L2M2M_ENCODER)
    list(APPEND avcodec_sources v4l2_m2m_enc.c)
endif()

if(CONFIG_HEVC_VIDEOTOOLBOX_ENCODER)
    list(APPEND avcodec_sources videotoolboxenc.c)
endif()

if(CONFIG_HUFFYUV_ENCODER)
    list(APPEND avcodec_sources huffyuv.c)
    list(APPEND avcodec_sources huffyuvenc.c)
endif()

if(CONFIG_JPEG2000_ENCODER)
    list(APPEND avcodec_sources j2kenc.c)
    list(APPEND avcodec_sources mqcenc.c)
    list(APPEND avcodec_sources mqc.c)
    list(APPEND avcodec_sources jpeg2000.c)
    list(APPEND avcodec_sources jpeg2000dwt.c)
endif()

if(CONFIG_JPEGLS_ENCODER)
    list(APPEND avcodec_sources jpeglsenc.c)
    list(APPEND avcodec_sources jpegls.c)
endif()

if(CONFIG_LJPEG_ENCODER)
    list(APPEND avcodec_sources ljpegenc.c)
    list(APPEND avcodec_sources mjpegenc_common.c)
endif()

if(CONFIG_MAGICYUV_ENCODER)
    list(APPEND avcodec_sources magicyuvenc.c)
endif()

if(CONFIG_MJPEG_ENCODER)
    list(APPEND avcodec_sources mjpegenc.c)
    list(APPEND avcodec_sources mjpegenc_common.c)
    list(APPEND avcodec_sources mjpegenc_huffman.c)
endif()

if(CONFIG_MJPEG_QSV_ENCODER)
    list(APPEND avcodec_sources qsvenc_jpeg.c)
endif()

if(CONFIG_MJPEG_VAAPI_ENCODER)
    list(APPEND avcodec_sources vaapi_encode_mjpeg.c)
endif()

if(CONFIG_MLP_ENCODER)
    list(APPEND avcodec_sources mlpenc.c)
    list(APPEND avcodec_sources mlp.c)
endif()

if(CONFIG_MOVTEXT_ENCODER)
    list(APPEND avcodec_sources movtextenc.c)
    list(APPEND avcodec_sources ass_split.c)
endif()

if(CONFIG_MP2_ENCODER)
    list(APPEND avcodec_sources mpegaudioenc.c)
    list(APPEND avcodec_sources mpegaudio.c)
    list(APPEND avcodec_sources mpegaudiodata.c)
    list(APPEND avcodec_sources mpegaudiodsp_data.c)
    list(APPEND avcodec_sources mpegaudiotabs.c)
endif()

if(CONFIG_MP2FIXED_ENCODER)
    list(APPEND avcodec_sources mpegaudioenc.c)
    list(APPEND avcodec_sources mpegaudio.c)
    list(APPEND avcodec_sources mpegaudiodata.c)
    list(APPEND avcodec_sources mpegaudiodsp_data.c)
    list(APPEND avcodec_sources mpegaudiotabs.c)
endif()

if(CONFIG_MP3_MF_ENCODER)
    list(APPEND avcodec_sources mfenc.c)
    list(APPEND avcodec_sources mf_utils.c)
endif()

if(CONFIG_MPEG1VIDEO_ENCODER)
    list(APPEND avcodec_sources mpeg12enc.c)
endif()

if(CONFIG_MPEG2_QSV_ENCODER)
    list(APPEND avcodec_sources qsvenc_mpeg2.c)
endif()

if(CONFIG_MPEG2VIDEO_ENCODER)
    list(APPEND avcodec_sources mpeg12enc.c)
endif()

if(CONFIG_MPEG2_VAAPI_ENCODER)
    list(APPEND avcodec_sources vaapi_encode_mpeg2.c)
endif()

if(CONFIG_MPEG4_ENCODER)
    list(APPEND avcodec_sources mpeg4videoenc.c)
endif()

if(CONFIG_MPEG4_MEDIACODEC_ENCODER)
    list(APPEND avcodec_sources mediacodecenc.c)
endif()

if(CONFIG_MPEG4_OMX_ENCODER)
    list(APPEND avcodec_sources omx.c)
endif()

if(CONFIG_MPEG4_V4L2M2M_ENCODER)
    list(APPEND avcodec_sources v4l2_m2m_enc.c)
endif()

if(CONFIG_MSRLE_ENCODER)
    list(APPEND avcodec_sources msrleenc.c)
endif()

if(CONFIG_MSVIDEO1_ENCODER)
    list(APPEND avcodec_sources msvideo1enc.c)
    list(APPEND avcodec_sources elbg.c)
endif()

if(CONFIG_NELLYMOSER_ENCODER)
    list(APPEND avcodec_sources nellymoserenc.c)
    list(APPEND avcodec_sources nellymoser.c)
endif()

if(CONFIG_PAM_ENCODER)
    list(APPEND avcodec_sources pamenc.c)
endif()

if(CONFIG_PBM_ENCODER)
    list(APPEND avcodec_sources pnmenc.c)
endif()

if(CONFIG_PCX_ENCODER)
    list(APPEND avcodec_sources pcxenc.c)
endif()

if(CONFIG_PFM_ENCODER)
    list(APPEND avcodec_sources pnmenc.c)
endif()

if(CONFIG_PGM_ENCODER)
    list(APPEND avcodec_sources pnmenc.c)
endif()

if(CONFIG_PGMYUV_ENCODER)
    list(APPEND avcodec_sources pnmenc.c)
endif()

if(CONFIG_PHM_ENCODER)
    list(APPEND avcodec_sources pnmenc.c)
endif()

if(CONFIG_PNG_ENCODER)
    list(APPEND avcodec_sources png.c)
    list(APPEND avcodec_sources pngenc.c)
endif()

if(CONFIG_PPM_ENCODER)
    list(APPEND avcodec_sources pnmenc.c)
endif()

if(CONFIG_PRORES_ENCODER)
    list(APPEND avcodec_sources proresenc_anatoliy.c)
    list(APPEND avcodec_sources proresdata.c)
endif()

if(CONFIG_PRORES_AW_ENCODER)
    list(APPEND avcodec_sources proresenc_anatoliy.c)
    list(APPEND avcodec_sources proresdata.c)
endif()

if(CONFIG_PRORES_KS_ENCODER)
    list(APPEND avcodec_sources proresenc_kostya.c)
    list(APPEND avcodec_sources proresdata.c)
    list(APPEND avcodec_sources proresenc_kostya_common.c)
endif()

if(CONFIG_PRORES_KS_VULKAN_ENCODER)
    list(APPEND avcodec_sources proresenc_kostya_vulkan.c)
    list(APPEND avcodec_sources proresdata.c)
    list(APPEND avcodec_sources proresenc_kostya_common.c)
endif()

if(CONFIG_PRORES_VIDEOTOOLBOX_ENCODER)
    list(APPEND avcodec_sources videotoolboxenc.c)
endif()

if(CONFIG_QOI_ENCODER)
    list(APPEND avcodec_sources qoienc.c)
endif()

if(CONFIG_QTRLE_ENCODER)
    list(APPEND avcodec_sources qtrleenc.c)
endif()

if(CONFIG_R10K_ENCODER)
    list(APPEND avcodec_sources r210enc.c)
endif()

if(CONFIG_R210_ENCODER)
    list(APPEND avcodec_sources r210enc.c)
endif()

if(CONFIG_RA_144_ENCODER)
    list(APPEND avcodec_sources ra144enc.c)
    list(APPEND avcodec_sources ra144.c)
    list(APPEND avcodec_sources celp_filters.c)
endif()

if(CONFIG_RAWVIDEO_ENCODER)
    list(APPEND avcodec_sources rawenc.c)
endif()

if(CONFIG_ROQ_ENCODER)
    list(APPEND avcodec_sources roqvideoenc.c)
    list(APPEND avcodec_sources roqvideo.c)
    list(APPEND avcodec_sources elbg.c)
endif()

if(CONFIG_ROQ_DPCM_ENCODER)
    list(APPEND avcodec_sources roqaudioenc.c)
endif()

if(CONFIG_RPZA_ENCODER)
    list(APPEND avcodec_sources rpzaenc.c)
endif()

if(CONFIG_RV10_ENCODER)
    list(APPEND avcodec_sources rv10enc.c)
endif()

if(CONFIG_RV20_ENCODER)
    list(APPEND avcodec_sources rv20enc.c)
endif()

if(CONFIG_S302M_ENCODER)
    list(APPEND avcodec_sources s302menc.c)
endif()

if(CONFIG_SGI_ENCODER)
    list(APPEND avcodec_sources sgienc.c)
    list(APPEND avcodec_sources rle.c)
endif()

if(CONFIG_SMC_ENCODER)
    list(APPEND avcodec_sources smcenc.c)
endif()

if(CONFIG_SNOW_ENCODER)
    list(APPEND avcodec_sources snowenc.c)
    list(APPEND avcodec_sources snow.c)
    list(APPEND avcodec_sources snow_dwt.c)
    list(APPEND avcodec_sources h263data.c)
    list(APPEND avcodec_sources ituh263enc.c)
    list(APPEND avcodec_sources motion_est.c)
    list(APPEND avcodec_sources ratecontrol.c)
endif()

if(CONFIG_SONIC_ENCODER)
    list(APPEND avcodec_sources sonic.c)
endif()

if(CONFIG_SONIC_LS_ENCODER)
    list(APPEND avcodec_sources sonic.c)
endif()

if(CONFIG_SPEEDHQ_ENCODER)
    list(APPEND avcodec_sources speedhq.c)
    list(APPEND avcodec_sources mpeg12data.c)
    list(APPEND avcodec_sources mpeg12enc.c)
    list(APPEND avcodec_sources speedhqenc.c)
endif()

if(CONFIG_SRT_ENCODER)
    list(APPEND avcodec_sources srtenc.c)
    list(APPEND avcodec_sources ass_split.c)
endif()

if(CONFIG_SUBRIP_ENCODER)
    list(APPEND avcodec_sources srtenc.c)
    list(APPEND avcodec_sources ass_split.c)
endif()

if(CONFIG_SUNRAST_ENCODER)
    list(APPEND avcodec_sources sunrastenc.c)
endif()

if(CONFIG_SBC_ENCODER)
    list(APPEND avcodec_sources sbcenc.c)
    list(APPEND avcodec_sources sbc.c)
    list(APPEND avcodec_sources sbcdsp.c)
endif()

if(CONFIG_SVQ1_ENCODER)
    list(APPEND avcodec_sources svq1enc.c)
    list(APPEND avcodec_sources svq1.c)
    list(APPEND avcodec_sources h263data.c)
    list(APPEND avcodec_sources h263.c)
    list(APPEND avcodec_sources ituh263enc.c)
    list(APPEND avcodec_sources motion_est.c)
endif()

if(CONFIG_TEXT_ENCODER)
    list(APPEND avcodec_sources srtenc.c)
    list(APPEND avcodec_sources ass_split.c)
endif()

if(CONFIG_TARGA_ENCODER)
    list(APPEND avcodec_sources targaenc.c)
    list(APPEND avcodec_sources rle.c)
endif()

if(CONFIG_TIFF_ENCODER)
    list(APPEND avcodec_sources tiffenc.c)
    list(APPEND avcodec_sources rle.c)
    list(APPEND avcodec_sources lzwenc.c)
endif()

if(CONFIG_TRUEHD_ENCODER)
    list(APPEND avcodec_sources mlpenc.c)
    list(APPEND avcodec_sources mlp.c)
endif()

if(CONFIG_TTA_ENCODER)
    list(APPEND avcodec_sources ttaenc.c)
    list(APPEND avcodec_sources ttaencdsp.c)
    list(APPEND avcodec_sources ttadata.c)
endif()

if(CONFIG_TTML_ENCODER)
    list(APPEND avcodec_sources ttmlenc.c)
    list(APPEND avcodec_sources ass_split.c)
endif()

if(CONFIG_UTVIDEO_ENCODER)
    list(APPEND avcodec_sources utvideoenc.c)
endif()

if(CONFIG_V210_ENCODER)
    list(APPEND avcodec_sources v210enc.c)
endif()

if(CONFIG_V308_ENCODER)
    list(APPEND avcodec_sources v308enc.c)
endif()

if(CONFIG_V408_ENCODER)
    list(APPEND avcodec_sources v408enc.c)
endif()

if(CONFIG_V410_ENCODER)
    list(APPEND avcodec_sources v410enc.c)
endif()

if(CONFIG_VBN_ENCODER)
    list(APPEND avcodec_sources vbnenc.c)
endif()

if(CONFIG_VC2_ENCODER)
    list(APPEND avcodec_sources vc2enc.c)
    list(APPEND avcodec_sources vc2enc_dwt.c)
    list(APPEND avcodec_sources diractab.c)
endif()

if(CONFIG_VNULL_ENCODER)
    list(APPEND avcodec_sources null.c)
endif()

if(CONFIG_VORBIS_ENCODER)
    list(APPEND avcodec_sources vorbisenc.c)
    list(APPEND avcodec_sources vorbis.c)
    list(APPEND avcodec_sources vorbis_data.c)
endif()

if(CONFIG_VP8_MEDIACODEC_ENCODER)
    list(APPEND avcodec_sources mediacodecenc.c)
endif()

if(CONFIG_VP8_VAAPI_ENCODER)
    list(APPEND avcodec_sources vaapi_encode_vp8.c)
endif()

if(CONFIG_VP8_V4L2M2M_ENCODER)
    list(APPEND avcodec_sources v4l2_m2m_enc.c)
endif()

if(CONFIG_VP9_MEDIACODEC_ENCODER)
    list(APPEND avcodec_sources mediacodecenc.c)
endif()

if(CONFIG_VP9_VAAPI_ENCODER)
    list(APPEND avcodec_sources vaapi_encode_vp9.c)
endif()

if(CONFIG_VP9_QSV_ENCODER)
    list(APPEND avcodec_sources qsvenc_vp9.c)
endif()

if(CONFIG_WAVPACK_ENCODER)
    list(APPEND avcodec_sources wavpackdata.c)
    list(APPEND avcodec_sources wavpackenc.c)
endif()

if(CONFIG_WBMP_ENCODER)
    list(APPEND avcodec_sources wbmpenc.c)
endif()

if(CONFIG_WEBVTT_ENCODER)
    list(APPEND avcodec_sources webvttenc.c)
    list(APPEND avcodec_sources ass_split.c)
endif()

if(CONFIG_WMAV1_ENCODER)
    list(APPEND avcodec_sources wmaenc.c)
    list(APPEND avcodec_sources wma.c)
    list(APPEND avcodec_sources wma_common.c)
    list(APPEND avcodec_sources aactab.c)
endif()

if(CONFIG_WMAV2_ENCODER)
    list(APPEND avcodec_sources wmaenc.c)
    list(APPEND avcodec_sources wma.c)
    list(APPEND avcodec_sources wma_common.c)
    list(APPEND avcodec_sources aactab.c)
endif()

if(CONFIG_WMV2_ENCODER)
    list(APPEND avcodec_sources wmv2enc.c)
    list(APPEND avcodec_sources wmv2data.c)
endif()

if(CONFIG_WRAPPED_AVFRAME_ENCODER)
    list(APPEND avcodec_sources wrapped_avframe.c)
endif()

if(CONFIG_XBM_ENCODER)
    list(APPEND avcodec_sources xbmenc.c)
endif()

if(CONFIG_XFACE_ENCODER)
    list(APPEND avcodec_sources xfaceenc.c)
    list(APPEND avcodec_sources xface.c)
endif()

if(CONFIG_XSUB_ENCODER)
    list(APPEND avcodec_sources xsubenc.c)
endif()

if(CONFIG_XWD_ENCODER)
    list(APPEND avcodec_sources xwdenc.c)
endif()

if(CONFIG_Y41P_ENCODER)
    list(APPEND avcodec_sources y41penc.c)
endif()

if(CONFIG_YUV4_ENCODER)
    list(APPEND avcodec_sources yuv4enc.c)
endif()

if(CONFIG_ZLIB_ENCODER)
    list(APPEND avcodec_sources lclenc.c)
endif()

if(CONFIG_ZMBV_ENCODER)
    list(APPEND avcodec_sources zmbvenc.c)
endif()

if(CONFIG_PCM_ALAW_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_BLURAY_ENCODER)
    list(APPEND avcodec_sources pcm-blurayenc.c)
endif()

if(CONFIG_PCM_DVD_ENCODER)
    list(APPEND avcodec_sources pcm-dvdenc.c)
endif()

if(CONFIG_PCM_F32BE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_F32LE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_F64BE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_F64LE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_MULAW_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S8_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S8_PLANAR_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S16BE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S16BE_PLANAR_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S16LE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S16LE_PLANAR_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S24BE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S24DAUD_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S24LE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S24LE_PLANAR_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S32BE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S32LE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S32LE_PLANAR_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S64BE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_S64LE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U8_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U16BE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U16LE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U24BE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U24LE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U32BE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_U32LE_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_PCM_VIDC_ENCODER)
    list(APPEND avcodec_sources pcm.c)
endif()

if(CONFIG_ADPCM_ADX_ENCODER)
    list(APPEND avcodec_sources adxenc.c)
    list(APPEND avcodec_sources adx.c)
endif()

if(CONFIG_ADPCM_ARGO_ENCODER)
    list(APPEND avcodec_sources adpcm.c)
    list(APPEND avcodec_sources adpcm_data.c)
    list(APPEND avcodec_sources adpcmenc.c)
endif()

if(CONFIG_ADPCM_G722_ENCODER)
    list(APPEND avcodec_sources g722.c)
    list(APPEND avcodec_sources g722dsp.c)
    list(APPEND avcodec_sources g722enc.c)
endif()

if(CONFIG_ADPCM_G726_ENCODER)
    list(APPEND avcodec_sources g726.c)
endif()

if(CONFIG_ADPCM_G726LE_ENCODER)
    list(APPEND avcodec_sources g726.c)
endif()

if(CONFIG_ADPCM_IMA_AMV_ENCODER)
    list(APPEND avcodec_sources adpcmenc.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_ALP_ENCODER)
    list(APPEND avcodec_sources adpcmenc.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_APM_ENCODER)
    list(APPEND avcodec_sources adpcmenc.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_QT_ENCODER)
    list(APPEND avcodec_sources adpcmenc.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_SSI_ENCODER)
    list(APPEND avcodec_sources adpcmenc.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_WAV_ENCODER)
    list(APPEND avcodec_sources adpcmenc.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_IMA_WS_ENCODER)
    list(APPEND avcodec_sources adpcmenc.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_MS_ENCODER)
    list(APPEND avcodec_sources adpcmenc.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_SWF_ENCODER)
    list(APPEND avcodec_sources adpcmenc.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_ADPCM_YAMAHA_ENCODER)
    list(APPEND avcodec_sources adpcmenc.c)
    list(APPEND avcodec_sources adpcm_data.c)
endif()

if(CONFIG_AAC_AT_ENCODER)
    list(APPEND avcodec_sources audiotoolboxenc.c)
endif()

if(CONFIG_ALAC_AT_ENCODER)
    list(APPEND avcodec_sources audiotoolboxenc.c)
endif()

if(CONFIG_ILBC_AT_ENCODER)
    list(APPEND avcodec_sources audiotoolboxenc.c)
endif()

if(CONFIG_PCM_ALAW_AT_ENCODER)
    list(APPEND avcodec_sources audiotoolboxenc.c)
endif()

if(CONFIG_PCM_MULAW_AT_ENCODER)
    list(APPEND avcodec_sources audiotoolboxenc.c)
endif()

if(CONFIG_LIBAOM_AV1_ENCODER)
    list(APPEND avcodec_sources libaomenc.c)
    list(APPEND avcodec_sources libaom.c)
endif()

if(CONFIG_LIBCODEC2_ENCODER)
    list(APPEND avcodec_sources libcodec2.c)
endif()

if(CONFIG_LIBFDK_AAC_ENCODER)
    list(APPEND avcodec_sources libfdk-aacenc.c)
endif()

if(CONFIG_LIBGSM_ENCODER)
    list(APPEND avcodec_sources libgsmenc.c)
endif()

if(CONFIG_LIBGSM_MS_ENCODER)
    list(APPEND avcodec_sources libgsmenc.c)
endif()

if(CONFIG_LIBILBC_ENCODER)
    list(APPEND avcodec_sources libilbc.c)
endif()

if(CONFIG_LIBJXL_ENCODER)
    list(APPEND avcodec_sources libjxlenc.c)
    list(APPEND avcodec_sources libjxl.c)
endif()

if(CONFIG_LIBKVAZAAR_ENCODER)
    list(APPEND avcodec_sources libkvazaar.c)
endif()

if(CONFIG_LIBLC3_ENCODER)
    list(APPEND avcodec_sources liblc3enc.c)
endif()

if(CONFIG_LIBMP3LAME_ENCODER)
    list(APPEND avcodec_sources libmp3lame.c)
endif()

if(CONFIG_LIBOAPV_ENCODER)
    list(APPEND avcodec_sources liboapvenc.c)
endif()

if(CONFIG_LIBOPENCORE_AMRNB_ENCODER)
    list(APPEND avcodec_sources libopencore-amr.c)
endif()

if(CONFIG_LIBOPENH264_ENCODER)
    list(APPEND avcodec_sources libopenh264enc.c)
    list(APPEND avcodec_sources libopenh264.c)
endif()

if(CONFIG_LIBOPENJPEG_ENCODER)
    list(APPEND avcodec_sources libopenjpegenc.c)
endif()

if(CONFIG_LIBOPUS_ENCODER)
    list(APPEND avcodec_sources libopusenc.c)
    list(APPEND avcodec_sources libopus.c)
    list(APPEND avcodec_sources vorbis_data.c)
endif()

if(CONFIG_LIBRAV1E_ENCODER)
    list(APPEND avcodec_sources librav1e.c)
endif()

if(CONFIG_LIBSHINE_ENCODER)
    list(APPEND avcodec_sources libshine.c)
endif()

if(CONFIG_LIBSPEEX_ENCODER)
    list(APPEND avcodec_sources libspeexenc.c)
endif()

if(CONFIG_LIBSVTAV1_ENCODER)
    list(APPEND avcodec_sources libsvtav1.c)
endif()

if(CONFIG_LIBSVTJPEGXS_ENCODER)
    list(APPEND avcodec_sources libsvtjpegxsenc.c)
endif()

if(CONFIG_LIBTHEORA_ENCODER)
    list(APPEND avcodec_sources libtheoraenc.c)
endif()

if(CONFIG_LIBTWOLAME_ENCODER)
    list(APPEND avcodec_sources libtwolame.c)
endif()

if(CONFIG_LIBVO_AMRWBENC_ENCODER)
    list(APPEND avcodec_sources libvo-amrwbenc.c)
endif()

if(CONFIG_LIBVORBIS_ENCODER)
    list(APPEND avcodec_sources libvorbisenc.c)
    list(APPEND avcodec_sources vorbis_data.c)
endif()

if(CONFIG_LIBVPX_VP8_ENCODER)
    list(APPEND avcodec_sources libvpxenc.c)
endif()

if(CONFIG_LIBVPX_VP9_ENCODER)
    list(APPEND avcodec_sources libvpxenc.c)
endif()

if(CONFIG_LIBVVENC_ENCODER)
    list(APPEND avcodec_sources libvvenc.c)
endif()

if(CONFIG_LIBWEBP_ENCODER)
    list(APPEND avcodec_sources libwebpenc_common.c)
    list(APPEND avcodec_sources libwebpenc.c)
endif()

if(CONFIG_LIBWEBP_ANIM_ENCODER)
    list(APPEND avcodec_sources libwebpenc_common.c)
    list(APPEND avcodec_sources libwebpenc_animencoder.c)
endif()

if(CONFIG_LIBX262_ENCODER)
    list(APPEND avcodec_sources libx264.c)
endif()

if(CONFIG_LIBX264_ENCODER)
    list(APPEND avcodec_sources libx264.c)
endif()

if(CONFIG_LIBX265_ENCODER)
    list(APPEND avcodec_sources libx265.c)
endif()

if(CONFIG_LIBXAVS_ENCODER)
    list(APPEND avcodec_sources libxavs.c)
endif()

if(CONFIG_LIBXAVS2_ENCODER)
    list(APPEND avcodec_sources libxavs2.c)
endif()

if(CONFIG_LIBXEVE_ENCODER)
    list(APPEND avcodec_sources libxeve.c)
endif()

if(CONFIG_LIBXVID_ENCODER)
    list(APPEND avcodec_sources libxvid.c)
endif()

if(CONFIG_FRAME_THREAD_ENCODER)
    list(APPEND avcodec_sources frame_thread_encoder.c)
endif()

if(CONFIG_OPUS_ENCODER)
    list(APPEND avcodec_sources opus/enc.c)
    list(APPEND avcodec_sources opus/enc_psy.c)
    list(APPEND avcodec_sources opus/celt.c)
    list(APPEND avcodec_sources opus/pvq.c)
    list(APPEND avcodec_sources opus/rc.c)
    list(APPEND avcodec_sources opus/tab.c)
endif()

# ============================================================================
# Parser sources (CONFIG_*_PARSER)
# ============================================================================

if(CONFIG_AAC_LATM_PARSER)
    list(APPEND avcodec_sources latm_parser.c)
endif()

if(CONFIG_AAC_PARSER)
    list(APPEND avcodec_sources aac_parser.c)
    list(APPEND avcodec_sources aac_ac3_parser.c)
endif()

if(CONFIG_AC3_PARSER)
    list(APPEND avcodec_sources aac_ac3_parser.c)
    list(APPEND avcodec_sources ac3tab.c)
    list(APPEND avcodec_sources ac3_channel_layout_tab.c)
endif()

if(CONFIG_ADX_PARSER)
    list(APPEND avcodec_sources adx_parser.c)
endif()

if(CONFIG_AHX_PARSER)
    list(APPEND avcodec_sources ahx_parser.c)
endif()

if(CONFIG_AMR_PARSER)
    list(APPEND avcodec_sources amr_parser.c)
endif()

if(CONFIG_APV_PARSER)
    list(APPEND avcodec_sources apv_parser.c)
endif()

if(CONFIG_AV1_PARSER)
    list(APPEND avcodec_sources av1_parser.c)
    list(APPEND avcodec_sources av1_parse.c)
endif()

if(CONFIG_AVS2_PARSER)
    list(APPEND avcodec_sources avs2.c)
    list(APPEND avcodec_sources avs2_parser.c)
endif()

if(CONFIG_AVS3_PARSER)
    list(APPEND avcodec_sources avs3_parser.c)
endif()

if(CONFIG_BMP_PARSER)
    list(APPEND avcodec_sources bmp_parser.c)
endif()

if(CONFIG_CAVSVIDEO_PARSER)
    list(APPEND avcodec_sources cavs_parser.c)
endif()

if(CONFIG_COOK_PARSER)
    list(APPEND avcodec_sources cook_parser.c)
endif()

if(CONFIG_CRI_PARSER)
    list(APPEND avcodec_sources cri_parser.c)
endif()

if(CONFIG_DCA_PARSER)
    list(APPEND avcodec_sources dca_parser.c)
    list(APPEND avcodec_sources dca_exss.c)
    list(APPEND avcodec_sources dca.c)
    list(APPEND avcodec_sources dca_sample_rate_tab.c)
endif()

if(CONFIG_DIRAC_PARSER)
    list(APPEND avcodec_sources dirac_parser.c)
endif()

if(CONFIG_DNXHD_PARSER)
    list(APPEND avcodec_sources dnxhd_parser.c)
    list(APPEND avcodec_sources dnxhddata.c)
endif()

if(CONFIG_DNXUC_PARSER)
    list(APPEND avcodec_sources dnxuc_parser.c)
endif()

if(CONFIG_DOLBY_E_PARSER)
    list(APPEND avcodec_sources dolby_e_parser.c)
    list(APPEND avcodec_sources dolby_e_parse.c)
endif()

if(CONFIG_DPX_PARSER)
    list(APPEND avcodec_sources dpx_parser.c)
endif()

if(CONFIG_DVAUDIO_PARSER)
    list(APPEND avcodec_sources dvaudio_parser.c)
endif()

if(CONFIG_DVBSUB_PARSER)
    list(APPEND avcodec_sources dvbsub_parser.c)
endif()

if(CONFIG_DVD_NAV_PARSER)
    list(APPEND avcodec_sources dvd_nav_parser.c)
endif()

if(CONFIG_DVDSUB_PARSER)
    list(APPEND avcodec_sources dvdsub_parser.c)
endif()

if(CONFIG_EVC_PARSER)
    list(APPEND avcodec_sources evc_parser.c)
endif()

if(CONFIG_FFV1_PARSER)
    list(APPEND avcodec_sources ffv1_parser.c)
    list(APPEND avcodec_sources ffv1_parse.c)
    list(APPEND avcodec_sources ffv1.c)
endif()

if(CONFIG_FLAC_PARSER)
    list(APPEND avcodec_sources flac_parser.c)
    list(APPEND avcodec_sources flacdata.c)
    list(APPEND avcodec_sources flac.c)
endif()

if(CONFIG_FTR_PARSER)
    list(APPEND avcodec_sources ftr_parser.c)
endif()

if(CONFIG_G723_1_PARSER)
    list(APPEND avcodec_sources g723_1_parser.c)
endif()

if(CONFIG_G729_PARSER)
    list(APPEND avcodec_sources g729_parser.c)
endif()

if(CONFIG_GIF_PARSER)
    list(APPEND avcodec_sources gif_parser.c)
endif()

if(CONFIG_GSM_PARSER)
    list(APPEND avcodec_sources gsm_parser.c)
endif()

if(CONFIG_H261_PARSER)
    list(APPEND avcodec_sources h261_parser.c)
endif()

if(CONFIG_H263_PARSER)
    list(APPEND avcodec_sources h263_parser.c)
endif()

if(CONFIG_H264_PARSER)
    list(APPEND avcodec_sources h264_parser.c)
    list(APPEND avcodec_sources h264data.c)
endif()

if(CONFIG_HDR_PARSER)
    list(APPEND avcodec_sources hdr_parser.c)
endif()

if(CONFIG_IPU_PARSER)
    list(APPEND avcodec_sources ipu_parser.c)
endif()

if(CONFIG_JPEG2000_PARSER)
    list(APPEND avcodec_sources jpeg2000_parser.c)
endif()

if(CONFIG_JPEGXL_PARSER)
    list(APPEND avcodec_sources jpegxl_parser.c)
    list(APPEND avcodec_sources jpegxl_parse.c)
endif()

if(CONFIG_JPEGXS_PARSER)
    list(APPEND avcodec_sources jpegxs_parser.c)
endif()

if(CONFIG_LCEVC_PARSER)
    list(APPEND avcodec_sources lcevc_parser.c)
    list(APPEND avcodec_sources lcevctab.c)
endif()

if(CONFIG_MISC4_PARSER)
    list(APPEND avcodec_sources misc4_parser.c)
endif()

if(CONFIG_MJPEG_PARSER)
    list(APPEND avcodec_sources mjpeg_parser.c)
endif()

if(CONFIG_MLP_PARSER)
    list(APPEND avcodec_sources mlp_parse.c)
    list(APPEND avcodec_sources mlp_parser.c)
    list(APPEND avcodec_sources mlp.c)
endif()

if(CONFIG_MPEG4VIDEO_PARSER)
    list(APPEND avcodec_sources mpeg4video_parser.c)
    list(APPEND avcodec_sources h263.c)
    list(APPEND avcodec_sources mpeg4videodec.c)
    list(APPEND avcodec_sources mpeg4video.c)
    list(APPEND avcodec_sources ituh263dec.c)
    list(APPEND avcodec_sources h263data.c)
endif()

if(CONFIG_MPEGAUDIO_PARSER)
    list(APPEND avcodec_sources mpegaudio_parser.c)
endif()

if(CONFIG_MPEGVIDEO_PARSER)
    list(APPEND avcodec_sources mpegvideo_parser.c)
    list(APPEND avcodec_sources mpeg12data.c)
endif()

if(CONFIG_OPUS_PARSER)
    list(APPEND avcodec_sources vorbis_data.c)
    list(APPEND avcodec_sources opus/frame_duration_tab.c)
    list(APPEND avcodec_sources opus/parser.c)
    list(APPEND avcodec_sources opus/parse.c)
endif()

if(CONFIG_PNG_PARSER)
    list(APPEND avcodec_sources png_parser.c)
endif()

if(CONFIG_PNM_PARSER)
    list(APPEND avcodec_sources pnm_parser.c)
    list(APPEND avcodec_sources pnm.c)
endif()

if(CONFIG_PRORES_RAW_PARSER)
    list(APPEND avcodec_sources prores_raw_parser.c)
endif()

if(CONFIG_QOI_PARSER)
    list(APPEND avcodec_sources qoi_parser.c)
endif()

if(CONFIG_PRORES_PARSER)
    list(APPEND avcodec_sources prores_parser.c)
endif()

if(CONFIG_RV34_PARSER)
    list(APPEND avcodec_sources rv34_parser.c)
endif()

if(CONFIG_SBC_PARSER)
    list(APPEND avcodec_sources sbc_parser.c)
endif()

if(CONFIG_SIPR_PARSER)
    list(APPEND avcodec_sources sipr_parser.c)
endif()

if(CONFIG_TAK_PARSER)
    list(APPEND avcodec_sources tak_parser.c)
    list(APPEND avcodec_sources tak.c)
endif()

if(CONFIG_VC1_PARSER)
    list(APPEND avcodec_sources vc1_parser.c)
    list(APPEND avcodec_sources vc1.c)
    list(APPEND avcodec_sources vc1data.c)
    list(APPEND avcodec_sources wmv2data.c)
endif()

if(CONFIG_VP3_PARSER)
    list(APPEND avcodec_sources vp3_parser.c)
endif()

if(CONFIG_VP8_PARSER)
    list(APPEND avcodec_sources vp8_parser.c)
endif()

if(CONFIG_VP9_PARSER)
    list(APPEND avcodec_sources vp9_parser.c)
endif()

if(CONFIG_VVC_PARSER)
    list(APPEND avcodec_sources vvc_parser.c)
endif()

if(CONFIG_WEBP_PARSER)
    list(APPEND avcodec_sources webp_parser.c)
endif()

if(CONFIG_XBM_PARSER)
    list(APPEND avcodec_sources xbm_parser.c)
endif()

if(CONFIG_XMA_PARSER)
    list(APPEND avcodec_sources xma_parser.c)
endif()

if(CONFIG_XWD_PARSER)
    list(APPEND avcodec_sources xwd_parser.c)
endif()

if(CONFIG_HEVC_PARSER)
    list(APPEND avcodec_sources hevc/parser.c)
endif()

# ============================================================================
# Hardware acceleration sources (CONFIG_*_HWACCEL)
# ============================================================================

if(CONFIG_AV1_D3D11VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_av1.c)
endif()

if(CONFIG_AV1_DXVA2_HWACCEL)
    list(APPEND avcodec_sources dxva2_av1.c)
endif()

if(CONFIG_AV1_D3D12VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_av1.c)
    list(APPEND avcodec_sources d3d12va_av1.c)
endif()

if(CONFIG_AV1_NVDEC_HWACCEL)
    list(APPEND avcodec_sources nvdec_av1.c)
endif()

if(CONFIG_AV1_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_av1.c)
endif()

if(CONFIG_AV1_VDPAU_HWACCEL)
    list(APPEND avcodec_sources vdpau_av1.c)
endif()

if(CONFIG_AV1_VIDEOTOOLBOX_HWACCEL)
    list(APPEND avcodec_sources videotoolbox_av1.c)
endif()

if(CONFIG_AV1_VULKAN_HWACCEL)
    list(APPEND avcodec_sources vulkan_decode.c)
    list(APPEND avcodec_sources vulkan_av1.c)
endif()

if(CONFIG_DPX_VULKAN_HWACCEL)
    list(APPEND avcodec_sources vulkan_decode.c)
    list(APPEND avcodec_sources vulkan_dpx.c)
endif()

if(CONFIG_FFV1_VULKAN_HWACCEL)
    list(APPEND avcodec_sources vulkan_decode.c)
    list(APPEND avcodec_sources ffv1_vulkan.c)
    list(APPEND avcodec_sources vulkan_ffv1.c)
endif()

if(CONFIG_H263_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_mpeg4.c)
endif()

if(CONFIG_H263_VIDEOTOOLBOX_HWACCEL)
    list(APPEND avcodec_sources videotoolbox.c)
endif()

if(CONFIG_H264_D3D11VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_h264.c)
endif()

if(CONFIG_H264_DXVA2_HWACCEL)
    list(APPEND avcodec_sources dxva2_h264.c)
endif()

if(CONFIG_H264_D3D12VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_h264.c)
    list(APPEND avcodec_sources d3d12va_h264.c)
endif()

if(CONFIG_H264_NVDEC_HWACCEL)
    list(APPEND avcodec_sources nvdec_h264.c)
endif()

if(CONFIG_H264_QSV_HWACCEL)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_H264_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_h264.c)
endif()

if(CONFIG_H264_VDPAU_HWACCEL)
    list(APPEND avcodec_sources vdpau_h264.c)
endif()

if(CONFIG_H264_VIDEOTOOLBOX_HWACCEL)
    list(APPEND avcodec_sources videotoolbox.c)
endif()

if(CONFIG_H264_VULKAN_HWACCEL)
    list(APPEND avcodec_sources vulkan_decode.c)
    list(APPEND avcodec_sources vulkan_h264.c)
endif()

if(CONFIG_HEVC_D3D11VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_hevc.c)
endif()

if(CONFIG_HEVC_DXVA2_HWACCEL)
    list(APPEND avcodec_sources dxva2_hevc.c)
endif()

if(CONFIG_HEVC_D3D12VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_hevc.c)
    list(APPEND avcodec_sources d3d12va_hevc.c)
endif()

if(CONFIG_HEVC_NVDEC_HWACCEL)
    list(APPEND avcodec_sources nvdec_hevc.c)
endif()

if(CONFIG_HEVC_QSV_HWACCEL)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_HEVC_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_hevc.c)
    list(APPEND avcodec_sources h265_profile_level.c)
endif()

if(CONFIG_HEVC_VDPAU_HWACCEL)
    list(APPEND avcodec_sources vdpau_hevc.c)
    list(APPEND avcodec_sources h265_profile_level.c)
endif()

if(CONFIG_HEVC_VULKAN_HWACCEL)
    list(APPEND avcodec_sources vulkan_decode.c)
    list(APPEND avcodec_sources vulkan_hevc.c)
endif()

if(CONFIG_MJPEG_NVDEC_HWACCEL)
    list(APPEND avcodec_sources nvdec_mjpeg.c)
endif()

if(CONFIG_MJPEG_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_mjpeg.c)
endif()

if(CONFIG_MPEG1_NVDEC_HWACCEL)
    list(APPEND avcodec_sources nvdec_mpeg12.c)
endif()

if(CONFIG_MPEG1_VDPAU_HWACCEL)
    list(APPEND avcodec_sources vdpau_mpeg12.c)
endif()

if(CONFIG_MPEG1_VIDEOTOOLBOX_HWACCEL)
    list(APPEND avcodec_sources videotoolbox.c)
endif()

if(CONFIG_MPEG2_D3D11VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_mpeg2.c)
endif()

if(CONFIG_MPEG2_DXVA2_HWACCEL)
    list(APPEND avcodec_sources dxva2_mpeg2.c)
endif()

if(CONFIG_MPEG2_D3D12VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_mpeg2.c)
    list(APPEND avcodec_sources d3d12va_mpeg2.c)
endif()

if(CONFIG_MPEG2_NVDEC_HWACCEL)
    list(APPEND avcodec_sources nvdec_mpeg12.c)
endif()

if(CONFIG_MPEG2_QSV_HWACCEL)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_MPEG2_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_mpeg2.c)
endif()

if(CONFIG_MPEG2_VDPAU_HWACCEL)
    list(APPEND avcodec_sources vdpau_mpeg12.c)
endif()

if(CONFIG_MPEG2_VIDEOTOOLBOX_HWACCEL)
    list(APPEND avcodec_sources videotoolbox.c)
endif()

if(CONFIG_MPEG4_NVDEC_HWACCEL)
    list(APPEND avcodec_sources nvdec_mpeg4.c)
endif()

if(CONFIG_MPEG4_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_mpeg4.c)
endif()

if(CONFIG_MPEG4_VDPAU_HWACCEL)
    list(APPEND avcodec_sources vdpau_mpeg4.c)
endif()

if(CONFIG_MPEG4_VIDEOTOOLBOX_HWACCEL)
    list(APPEND avcodec_sources videotoolbox.c)
endif()

if(CONFIG_VC1_D3D11VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_vc1.c)
endif()

if(CONFIG_VC1_DXVA2_HWACCEL)
    list(APPEND avcodec_sources dxva2_vc1.c)
endif()

if(CONFIG_VC1_D3D12VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_vc1.c)
    list(APPEND avcodec_sources d3d12va_vc1.c)
endif()

if(CONFIG_VC1_NVDEC_HWACCEL)
    list(APPEND avcodec_sources nvdec_vc1.c)
endif()

if(CONFIG_VC1_QSV_HWACCEL)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_VC1_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_vc1.c)
endif()

if(CONFIG_VC1_VDPAU_HWACCEL)
    list(APPEND avcodec_sources vdpau_vc1.c)
endif()

if(CONFIG_VP8_NVDEC_HWACCEL)
    list(APPEND avcodec_sources nvdec_vp8.c)
endif()

if(CONFIG_VP8_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_vp8.c)
endif()

if(CONFIG_VP9_D3D11VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_vp9.c)
endif()

if(CONFIG_VP9_DXVA2_HWACCEL)
    list(APPEND avcodec_sources dxva2_vp9.c)
endif()

if(CONFIG_VP9_D3D12VA_HWACCEL)
    list(APPEND avcodec_sources dxva2_vp9.c)
    list(APPEND avcodec_sources d3d12va_vp9.c)
endif()

if(CONFIG_VP9_NVDEC_HWACCEL)
    list(APPEND avcodec_sources nvdec_vp9.c)
endif()

if(CONFIG_VP9_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_vp9.c)
endif()

if(CONFIG_VP9_VDPAU_HWACCEL)
    list(APPEND avcodec_sources vdpau_vp9.c)
endif()

if(CONFIG_VP9_VIDEOTOOLBOX_HWACCEL)
    list(APPEND avcodec_sources videotoolbox_vp9.c)
endif()

if(CONFIG_VP9_VULKAN_HWACCEL)
    list(APPEND avcodec_sources vulkan_decode.c)
    list(APPEND avcodec_sources vulkan_vp9.c)
endif()

if(CONFIG_VP8_QSV_HWACCEL)
    list(APPEND avcodec_sources qsvdec.c)
endif()

if(CONFIG_VVC_VAAPI_HWACCEL)
    list(APPEND avcodec_sources vaapi_vvc.c)
endif()

if(CONFIG_PRORES_RAW_VULKAN_HWACCEL)
    list(APPEND avcodec_sources vulkan_decode.c)
    list(APPEND avcodec_sources vulkan_prores_raw.c)
endif()

if(CONFIG_PRORES_VULKAN_HWACCEL)
    list(APPEND avcodec_sources vulkan_decode.c)
    list(APPEND avcodec_sources vulkan_prores.c)
endif()

# ============================================================================
# Bitstream filter sources (CONFIG_*_BSF)
# ============================================================================

if(CONFIG_EXTRACT_EXTRADATA_BSF)
    list(APPEND avcodec_sources av1_parse.c)
    list(APPEND avcodec_sources h2645_parse.c)
    list(APPEND avcodec_sources bsf/extract_extradata.c)
endif()

if(CONFIG_H264_METADATA_BSF)
    list(APPEND avcodec_sources h264_levels.c)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources bsf/h264_metadata.c)
endif()

if(CONFIG_HAPQA_EXTRACT_BSF)
    list(APPEND avcodec_sources hap.c)
    list(APPEND avcodec_sources bsf/hapqa_extract.c)
endif()

if(CONFIG_HEVC_METADATA_BSF)
    list(APPEND avcodec_sources h265_profile_level.c)
    list(APPEND avcodec_sources h2645data.c)
    list(APPEND avcodec_sources bsf/h265_metadata.c)
endif()

if(CONFIG_REMOVE_EXTRADATA_BSF)
    list(APPEND avcodec_sources av1_parse.c)
    list(APPEND avcodec_sources bsf/remove_extradata.c)
endif()

if(CONFIG_TRUEHD_CORE_BSF)
    list(APPEND avcodec_sources mlp_parse.c)
    list(APPEND avcodec_sources mlp.c)
    list(APPEND avcodec_sources bsf/truehd_core.c)
endif()

if(CONFIG_AAC_ADTSTOASC_BSF)
    list(APPEND avcodec_sources bsf/aac_adtstoasc.c)
endif()

if(CONFIG_AHX_TO_MP2_BSF)
    list(APPEND avcodec_sources bsf/ahx_to_mp2.c)
endif()

if(CONFIG_APV_METADATA_BSF)
    list(APPEND avcodec_sources bsf/apv_metadata.c)
endif()

if(CONFIG_AV1_FRAME_MERGE_BSF)
    list(APPEND avcodec_sources bsf/av1_frame_merge.c)
endif()

if(CONFIG_AV1_FRAME_SPLIT_BSF)
    list(APPEND avcodec_sources bsf/av1_frame_split.c)
endif()

if(CONFIG_AV1_METADATA_BSF)
    list(APPEND avcodec_sources bsf/av1_metadata.c)
endif()

if(CONFIG_CHOMP_BSF)
    list(APPEND avcodec_sources bsf/chomp.c)
endif()

if(CONFIG_DCA_CORE_BSF)
    list(APPEND avcodec_sources bsf/dca_core.c)
endif()

if(CONFIG_DTS2PTS_BSF)
    list(APPEND avcodec_sources bsf/dts2pts.c)
endif()

if(CONFIG_DUMP_EXTRADATA_BSF)
    list(APPEND avcodec_sources bsf/dump_extradata.c)
endif()

if(CONFIG_DV_ERROR_MARKER_BSF)
    list(APPEND avcodec_sources bsf/dv_error_marker.c)
endif()

if(CONFIG_EAC3_CORE_BSF)
    list(APPEND avcodec_sources bsf/eac3_core.c)
endif()

if(CONFIG_EIA608_TO_SMPTE436M_BSF)
    list(APPEND avcodec_sources bsf/eia608_to_smpte436m.c)
endif()

if(CONFIG_EVC_FRAME_MERGE_BSF)
    list(APPEND avcodec_sources bsf/evc_frame_merge.c)
endif()

if(CONFIG_FILTER_UNITS_BSF)
    list(APPEND avcodec_sources bsf/filter_units.c)
endif()

if(CONFIG_H264_MP4TOANNEXB_BSF)
    list(APPEND avcodec_sources bsf/h264_mp4toannexb.c)
endif()

if(CONFIG_H264_REDUNDANT_PPS_BSF)
    list(APPEND avcodec_sources bsf/h264_redundant_pps.c)
endif()

if(CONFIG_DOVI_RPU_BSF)
    list(APPEND avcodec_sources bsf/dovi_rpu.c)
endif()

if(CONFIG_HEVC_MP4TOANNEXB_BSF)
    list(APPEND avcodec_sources bsf/hevc_mp4toannexb.c)
endif()

if(CONFIG_IMX_DUMP_HEADER_BSF)
    list(APPEND avcodec_sources bsf/imx_dump_header.c)
endif()

if(CONFIG_LCEVC_METADATA_BSF)
    list(APPEND avcodec_sources bsf/lcevc_metadata.c)
endif()

if(CONFIG_MEDIA100_TO_MJPEGB_BSF)
    list(APPEND avcodec_sources bsf/media100_to_mjpegb.c)
endif()

if(CONFIG_MJPEG2JPEG_BSF)
    list(APPEND avcodec_sources bsf/mjpeg2jpeg.c)
endif()

if(CONFIG_MJPEGA_DUMP_HEADER_BSF)
    list(APPEND avcodec_sources bsf/mjpega_dump_header.c)
endif()

if(CONFIG_MOV2TEXTSUB_BSF)
    list(APPEND avcodec_sources bsf/movsub.c)
endif()

if(CONFIG_MPEG2_METADATA_BSF)
    list(APPEND avcodec_sources bsf/mpeg2_metadata.c)
endif()

if(CONFIG_MPEG4_UNPACK_BFRAMES_BSF)
    list(APPEND avcodec_sources bsf/mpeg4_unpack_bframes.c)
endif()

if(CONFIG_NOISE_BSF)
    list(APPEND avcodec_sources bsf/noise.c)
endif()

if(CONFIG_NULL_BSF)
    list(APPEND avcodec_sources bsf/null.c)
endif()

if(CONFIG_OPUS_METADATA_BSF)
    list(APPEND avcodec_sources bsf/opus_metadata.c)
endif()

if(CONFIG_PCM_RECHUNK_BSF)
    list(APPEND avcodec_sources bsf/pcm_rechunk.c)
endif()

if(CONFIG_PGS_FRAME_MERGE_BSF)
    list(APPEND avcodec_sources bsf/pgs_frame_merge.c)
endif()

if(CONFIG_PRORES_METADATA_BSF)
    list(APPEND avcodec_sources bsf/prores_metadata.c)
endif()

if(CONFIG_SETTS_BSF)
    list(APPEND avcodec_sources bsf/setts.c)
endif()

if(CONFIG_SHOWINFO_BSF)
    list(APPEND avcodec_sources bsf/showinfo.c)
endif()

if(CONFIG_SMPTE436M_TO_EIA608_BSF)
    list(APPEND avcodec_sources bsf/smpte436m_to_eia608.c)
endif()

if(CONFIG_TEXT2MOVSUB_BSF)
    list(APPEND avcodec_sources bsf/movsub.c)
endif()

if(CONFIG_TRACE_HEADERS_BSF)
    list(APPEND avcodec_sources bsf/trace_headers.c)
endif()

if(CONFIG_VP9_METADATA_BSF)
    list(APPEND avcodec_sources bsf/vp9_metadata.c)
endif()

if(CONFIG_VP9_RAW_REORDER_BSF)
    list(APPEND avcodec_sources bsf/vp9_raw_reorder.c)
endif()

if(CONFIG_VP9_SUPERFRAME_BSF)
    list(APPEND avcodec_sources bsf/vp9_superframe.c)
endif()

if(CONFIG_VP9_SUPERFRAME_SPLIT_BSF)
    list(APPEND avcodec_sources bsf/vp9_superframe_split.c)
endif()

if(CONFIG_VVC_METADATA_BSF)
    list(APPEND avcodec_sources bsf/h266_metadata.c)
endif()

if(CONFIG_VVC_MP4TOANNEXB_BSF)
    list(APPEND avcodec_sources bsf/vvc_mp4toannexb.c)
endif()

# ============================================================================
# x86 architecture-specific sources
# ============================================================================
if(ARCH_X86 AND ENABLE_ASM)

    # Unconditional x86 sources
    list(APPEND avcodec_sources x86/constants.c)

    # x86 C sources (conditional)
    if(CONFIG_FDCTDSP)
        list(APPEND avcodec_sources x86/fdctdsp_init.c)
        list(APPEND avcodec_sources x86/fdct.c)
    endif()

    if(CONFIG_LLVIDENCDSP)
        list(APPEND avcodec_sources x86/lossless_videoencdsp_init.c)
    endif()

    if(CONFIG_LPC)
        list(APPEND avcodec_sources x86/lpc_init.c)
    endif()

    if(CONFIG_MPEGAUDIODSP)
        list(APPEND avcodec_sources x86/mpegaudiodsp.c)
    endif()

    if(CONFIG_MPEGVIDEO)
        list(APPEND avcodec_sources x86/mpegvideo.c)
    endif()

    if(CONFIG_MPEGVIDEOENC)
        list(APPEND avcodec_sources x86/mpegvideoenc.c)
    endif()

    if(CONFIG_MPEGVIDEOENCDSP)
        list(APPEND avcodec_sources x86/mpegvideoencdsp_init.c)
    endif()

    if(CONFIG_XMM_CLOBBER_TEST)
        list(APPEND avcodec_sources x86/w64xmmtest.c)
    endif()

    if(CONFIG_MLP_DECODER)
        list(APPEND avcodec_sources x86/mlpdsp_init.c)
    endif()

    if(CONFIG_MPEG4_DECODER)
        list(APPEND avcodec_sources x86/mpeg4videodsp.c)
    endif()

    if(CONFIG_SNOW_DECODER)
        list(APPEND avcodec_sources x86/snowdsp.c)
    endif()

    if(CONFIG_SNOW_ENCODER)
        list(APPEND avcodec_sources x86/snowdsp.c)
    endif()

    if(CONFIG_TRUEHD_DECODER)
        list(APPEND avcodec_sources x86/mlpdsp_init.c)
    endif()

    if(HAVE_X86ASM)
        # x86 ASM sources (conditional, require NASM/YASM)
        if(CONFIG_AC3DSP)
            list(APPEND avcodec_sources x86/ac3dsp_init.c)
            list(APPEND avcodec_sources x86/ac3dsp.asm)
            list(APPEND avcodec_sources x86/ac3dsp_downmix.asm)
        endif()

        if(CONFIG_AUDIODSP)
            list(APPEND avcodec_sources x86/audiodsp_init.c)
            list(APPEND avcodec_sources x86/audiodsp.asm)
        endif()

        if(CONFIG_BLOCKDSP)
            list(APPEND avcodec_sources x86/blockdsp_init.c)
            list(APPEND avcodec_sources x86/blockdsp.asm)
        endif()

        if(CONFIG_BSWAPDSP)
            list(APPEND avcodec_sources x86/bswapdsp_init.c)
            list(APPEND avcodec_sources x86/bswapdsp.asm)
        endif()

        if(CONFIG_DIRAC_DECODER)
            list(APPEND avcodec_sources x86/diracdsp_init.c)
            list(APPEND avcodec_sources x86/dirac_dwt_init.c)
            list(APPEND avcodec_sources x86/diracdsp.asm)
            list(APPEND avcodec_sources x86/dirac_dwt.asm)
        endif()

        if(CONFIG_FMTCONVERT)
            list(APPEND avcodec_sources x86/fmtconvert_init.c)
            list(APPEND avcodec_sources x86/fmtconvert.asm)
        endif()

        if(CONFIG_H263DSP)
            list(APPEND avcodec_sources x86/h263dsp_init.c)
            list(APPEND avcodec_sources x86/h263_loopfilter.asm)
        endif()

        if(CONFIG_H264CHROMA)
            list(APPEND avcodec_sources x86/h264chroma_init.c)
            list(APPEND avcodec_sources x86/h264_chromamc.asm)
            list(APPEND avcodec_sources x86/h264_chromamc_10bit.asm)
        endif()

        if(CONFIG_H264DSP)
            list(APPEND avcodec_sources x86/h264dsp_init.c)
            list(APPEND avcodec_sources x86/h264_deblock.asm)
            list(APPEND avcodec_sources x86/h264_deblock_10bit.asm)
            list(APPEND avcodec_sources x86/h264_idct.asm)
            list(APPEND avcodec_sources x86/h264_idct_10bit.asm)
            list(APPEND avcodec_sources x86/h264_weight.asm)
            list(APPEND avcodec_sources x86/h264_weight_10bit.asm)
        endif()

        if(CONFIG_H264PRED)
            list(APPEND avcodec_sources x86/h264_intrapred_init.c)
            list(APPEND avcodec_sources x86/h264_intrapred.asm)
            list(APPEND avcodec_sources x86/h264_intrapred_10bit.asm)
        endif()

        if(CONFIG_H264QPEL)
            list(APPEND avcodec_sources x86/h264_qpel.c)
            list(APPEND avcodec_sources x86/h264_qpel_8bit.asm)
            list(APPEND avcodec_sources x86/h264_qpel_10bit.asm)
            list(APPEND avcodec_sources x86/fpel.asm)
            list(APPEND avcodec_sources x86/qpel.asm)
        endif()

        if(CONFIG_HPELDSP)
            list(APPEND avcodec_sources x86/hpeldsp_init.c)
            list(APPEND avcodec_sources x86/fpel.asm)
            list(APPEND avcodec_sources x86/hpeldsp.asm)
        endif()

        if(CONFIG_HUFFYUVDSP)
            list(APPEND avcodec_sources x86/huffyuvdsp_init.c)
            list(APPEND avcodec_sources x86/huffyuvdsp.asm)
        endif()

        if(CONFIG_HUFFYUVENCDSP)
            list(APPEND avcodec_sources x86/huffyuvencdsp_init.c)
            list(APPEND avcodec_sources x86/huffyuvencdsp.asm)
        endif()

        if(CONFIG_IDCTDSP)
            list(APPEND avcodec_sources x86/idctdsp_init.c)
            list(APPEND avcodec_sources x86/idctdsp.asm)
            list(APPEND avcodec_sources x86/simple_idct10.asm)
            list(APPEND avcodec_sources x86/simple_idct.asm)
        endif()

        if(CONFIG_LLAUDDSP)
            list(APPEND avcodec_sources x86/lossless_audiodsp_init.c)
            list(APPEND avcodec_sources x86/lossless_audiodsp.asm)
        endif()

        if(CONFIG_LLVIDDSP)
            list(APPEND avcodec_sources x86/lossless_videodsp_init.c)
            list(APPEND avcodec_sources x86/lossless_videodsp.asm)
        endif()

        if(CONFIG_ME_CMP)
            list(APPEND avcodec_sources x86/me_cmp_init.c)
            list(APPEND avcodec_sources x86/me_cmp.asm)
        endif()

        if(CONFIG_PIXBLOCKDSP)
            list(APPEND avcodec_sources x86/pixblockdsp_init.c)
            list(APPEND avcodec_sources x86/pixblockdsp.asm)
        endif()

        if(CONFIG_QPELDSP)
            list(APPEND avcodec_sources x86/qpeldsp_init.c)
            list(APPEND avcodec_sources x86/qpeldsp.asm)
            list(APPEND avcodec_sources x86/fpel.asm)
            list(APPEND avcodec_sources x86/qpel.asm)
        endif()

        if(CONFIG_RV34DSP)
            list(APPEND avcodec_sources x86/rv34dsp_init.c)
            list(APPEND avcodec_sources x86/rv34dsp.asm)
        endif()

        if(CONFIG_VC1DSP)
            list(APPEND avcodec_sources x86/vc1dsp_init.c)
            list(APPEND avcodec_sources x86/vc1dsp_mmx.c)
            list(APPEND avcodec_sources x86/vc1dsp_loopfilter.asm)
            list(APPEND avcodec_sources x86/vc1dsp_mc.asm)
            list(APPEND avcodec_sources x86/fpel.asm)
        endif()

        if(CONFIG_VIDEODSP)
            list(APPEND avcodec_sources x86/videodsp_init.c)
            list(APPEND avcodec_sources x86/videodsp.asm)
        endif()

        if(CONFIG_VP3DSP)
            list(APPEND avcodec_sources x86/vp3dsp_init.c)
            list(APPEND avcodec_sources x86/vp3dsp.asm)
        endif()

        if(CONFIG_VP8DSP)
            list(APPEND avcodec_sources x86/vp8dsp_init.c)
            list(APPEND avcodec_sources x86/vp8dsp.asm)
            list(APPEND avcodec_sources x86/vp8dsp_loopfilter.asm)
        endif()

        if(CONFIG_AAC_DECODER)
            list(APPEND avcodec_sources x86/aacpsdsp_init.c)
            list(APPEND avcodec_sources x86/sbrdsp_init.c)
            list(APPEND avcodec_sources x86/aacpsdsp.asm)
            list(APPEND avcodec_sources x86/sbrdsp.asm)
        endif()

        if(CONFIG_AAC_ENCODER)
            list(APPEND avcodec_sources x86/aacencdsp_init.c)
            list(APPEND avcodec_sources x86/aacencdsp.asm)
        endif()

        if(CONFIG_ADPCM_G722_DECODER)
            list(APPEND avcodec_sources x86/g722dsp_init.c)
            list(APPEND avcodec_sources x86/g722dsp.asm)
        endif()

        if(CONFIG_ADPCM_G722_ENCODER)
            list(APPEND avcodec_sources x86/g722dsp_init.c)
            list(APPEND avcodec_sources x86/g722dsp.asm)
        endif()

        if(CONFIG_ALAC_DECODER)
            list(APPEND avcodec_sources x86/alacdsp_init.c)
            list(APPEND avcodec_sources x86/alacdsp.asm)
        endif()

        if(CONFIG_APNG_DECODER)
            list(APPEND avcodec_sources x86/pngdsp_init.c)
            list(APPEND avcodec_sources x86/pngdsp.asm)
        endif()

        if(CONFIG_APV_DECODER)
            list(APPEND avcodec_sources x86/apv_dsp_init.c)
            list(APPEND avcodec_sources x86/apv_dsp.asm)
        endif()

        if(CONFIG_CAVS_DECODER)
            list(APPEND avcodec_sources x86/cavsdsp.c)
            list(APPEND avcodec_sources x86/cavsidct.asm)
            list(APPEND avcodec_sources x86/cavs_qpel.asm)
        endif()

        if(CONFIG_CFHD_DECODER)
            list(APPEND avcodec_sources x86/cfhddsp_init.c)
            list(APPEND avcodec_sources x86/cfhddsp.asm)
        endif()

        if(CONFIG_CFHD_ENCODER)
            list(APPEND avcodec_sources x86/cfhdencdsp_init.c)
            list(APPEND avcodec_sources x86/cfhdencdsp.asm)
        endif()

        if(CONFIG_DCA_DECODER)
            list(APPEND avcodec_sources x86/dcadsp_init.c)
            list(APPEND avcodec_sources x86/synth_filter_init.c)
            list(APPEND avcodec_sources x86/dcadsp.asm)
            list(APPEND avcodec_sources x86/synth_filter.asm)
        endif()

        if(CONFIG_DNXHD_ENCODER)
            list(APPEND avcodec_sources x86/dnxhdenc_init.c)
            list(APPEND avcodec_sources x86/dnxhdenc.asm)
        endif()

        if(CONFIG_EXR_DECODER)
            list(APPEND avcodec_sources x86/exrdsp_init.c)
            list(APPEND avcodec_sources x86/exrdsp.asm)
        endif()

        if(CONFIG_FLAC_DECODER)
            list(APPEND avcodec_sources x86/flacdsp_init.c)
            list(APPEND avcodec_sources x86/flacdsp.asm)
        endif()

        if(CONFIG_FLAC_ENCODER)
            list(APPEND avcodec_sources x86/flacencdsp_init.c)
            list(APPEND avcodec_sources x86/flac_dsp_gpl.asm)
        endif()

        if(CONFIG_OPUS_DECODER)
            list(APPEND avcodec_sources x86/opusdsp_init.c)
            list(APPEND avcodec_sources x86/opusdsp.asm)
        endif()

        if(CONFIG_OPUS_ENCODER)
            list(APPEND avcodec_sources x86/celt_pvq_init.c)
            list(APPEND avcodec_sources x86/celt_pvq_search.asm)
        endif()

        if(CONFIG_JPEG2000_DECODER)
            list(APPEND avcodec_sources x86/jpeg2000dsp_init.c)
            list(APPEND avcodec_sources x86/jpeg2000dsp.asm)
        endif()

        if(CONFIG_LSCR_DECODER)
            list(APPEND avcodec_sources x86/pngdsp_init.c)
            list(APPEND avcodec_sources x86/pngdsp.asm)
        endif()

        if(CONFIG_MPEG4_DECODER)
            list(APPEND avcodec_sources x86/xvididct_init.c)
            list(APPEND avcodec_sources x86/xvididct.asm)
        endif()

        if(CONFIG_PNG_DECODER)
            list(APPEND avcodec_sources x86/pngdsp_init.c)
            list(APPEND avcodec_sources x86/pngdsp.asm)
        endif()

        if(CONFIG_PRORES_DECODER)
            list(APPEND avcodec_sources x86/proresdsp_init.c)
            list(APPEND avcodec_sources x86/proresdsp.asm)
        endif()

        if(CONFIG_PRORES_RAW_DECODER)
            list(APPEND avcodec_sources x86/proresdsp_init.c)
            list(APPEND avcodec_sources x86/proresdsp.asm)
        endif()

        if(CONFIG_RV40_DECODER)
            list(APPEND avcodec_sources x86/rv40dsp_init.c)
            list(APPEND avcodec_sources x86/rv40dsp.asm)
        endif()

        if(CONFIG_SBC_ENCODER)
            list(APPEND avcodec_sources x86/sbcdsp_init.c)
            list(APPEND avcodec_sources x86/sbcdsp.asm)
        endif()

        if(CONFIG_SVQ1_ENCODER)
            list(APPEND avcodec_sources x86/svq1enc_init.c)
            list(APPEND avcodec_sources x86/svq1enc.asm)
        endif()

        if(CONFIG_TAK_DECODER)
            list(APPEND avcodec_sources x86/takdsp_init.c)
            list(APPEND avcodec_sources x86/takdsp.asm)
        endif()

        if(CONFIG_TTA_DECODER)
            list(APPEND avcodec_sources x86/ttadsp_init.c)
            list(APPEND avcodec_sources x86/ttadsp.asm)
        endif()

        if(CONFIG_TTA_ENCODER)
            list(APPEND avcodec_sources x86/ttaencdsp_init.c)
            list(APPEND avcodec_sources x86/ttaencdsp.asm)
        endif()

        if(CONFIG_UTVIDEO_DECODER)
            list(APPEND avcodec_sources x86/utvideodsp_init.c)
            list(APPEND avcodec_sources x86/utvideodsp.asm)
        endif()

        if(CONFIG_V210_DECODER)
            list(APPEND avcodec_sources x86/v210-init.c)
            list(APPEND avcodec_sources x86/v210.asm)
        endif()

        if(CONFIG_V210_ENCODER)
            list(APPEND avcodec_sources x86/v210enc_init.c)
            list(APPEND avcodec_sources x86/v210enc.asm)
        endif()

        if(CONFIG_VORBIS_DECODER)
            list(APPEND avcodec_sources x86/vorbisdsp_init.c)
            list(APPEND avcodec_sources x86/vorbisdsp.asm)
        endif()

        if(CONFIG_VP6_DECODER)
            list(APPEND avcodec_sources x86/vp6dsp_init.c)
            list(APPEND avcodec_sources x86/vp6dsp.asm)
        endif()

        if(CONFIG_VP9_DECODER)
            list(APPEND avcodec_sources x86/vp9dsp_init.c)
            list(APPEND avcodec_sources x86/vp9dsp_init_10bpp.c)
            list(APPEND avcodec_sources x86/vp9dsp_init_12bpp.c)
            list(APPEND avcodec_sources x86/vp9dsp_init_16bpp.c)
            list(APPEND avcodec_sources x86/vp9intrapred.asm)
            list(APPEND avcodec_sources x86/vp9intrapred_16bpp.asm)
            list(APPEND avcodec_sources x86/vp9itxfm.asm)
            list(APPEND avcodec_sources x86/vp9itxfm_avx2.asm)
            list(APPEND avcodec_sources x86/vp9itxfm_avx512.asm)
            list(APPEND avcodec_sources x86/vp9itxfm_16bpp.asm)
            list(APPEND avcodec_sources x86/vp9itxfm_16bpp_avx512.asm)
            list(APPEND avcodec_sources x86/vp9lpf.asm)
            list(APPEND avcodec_sources x86/vp9lpf_16bpp.asm)
            list(APPEND avcodec_sources x86/vp9mc.asm)
            list(APPEND avcodec_sources x86/vp9mc_16bpp.asm)
        endif()

        if(CONFIG_LLVIDENCDSP)
            list(APPEND avcodec_sources x86/lossless_videoencdsp.asm)
        endif()

        if(CONFIG_LPC)
            list(APPEND avcodec_sources x86/lpc.asm)
        endif()

        if(CONFIG_MPEGAUDIODSP)
            list(APPEND avcodec_sources x86/dct32.asm)
            list(APPEND avcodec_sources x86/imdct36.asm)
        endif()

        if(CONFIG_MPEGVIDEOENCDSP)
            list(APPEND avcodec_sources x86/mpegvideoencdsp.asm)
        endif()

        if(CONFIG_MLP_DECODER)
            list(APPEND avcodec_sources x86/mlpdsp.asm)
        endif()

        if(CONFIG_TRUEHD_DECODER)
            list(APPEND avcodec_sources x86/mlpdsp.asm)
        endif()

        if(CONFIG_HEVC_DECODER)
            list(APPEND avcodec_sources x86/hevc/dsp_init.c)
            list(APPEND avcodec_sources x86/hevc/add_res.asm)
            list(APPEND avcodec_sources x86/hevc/deblock.asm)
            list(APPEND avcodec_sources x86/hevc/dequant.asm)
            list(APPEND avcodec_sources x86/hevc/idct.asm)
            list(APPEND avcodec_sources x86/hevc/mc.asm)
            list(APPEND avcodec_sources x86/hevc/sao.asm)
            list(APPEND avcodec_sources x86/hevc/sao_10bit.asm)
            list(APPEND avcodec_sources x86/h26x/h2656dsp.c)
            list(APPEND avcodec_sources x86/h26x/h2656_inter.asm)
        endif()

        if(CONFIG_VVC_DECODER)
            list(APPEND avcodec_sources x86/vvc/dsp_init.c)
            list(APPEND avcodec_sources x86/vvc/alf.asm)
            list(APPEND avcodec_sources x86/vvc/dmvr.asm)
            list(APPEND avcodec_sources x86/vvc/mc.asm)
            list(APPEND avcodec_sources x86/vvc/of.asm)
            list(APPEND avcodec_sources x86/vvc/sad.asm)
            list(APPEND avcodec_sources x86/vvc/sao.asm)
            list(APPEND avcodec_sources x86/vvc/sao_10bit.asm)
            list(APPEND avcodec_sources x86/h26x/h2656dsp.c)
            list(APPEND avcodec_sources x86/h26x/h2656_inter.asm)
        endif()

    endif()
endif()

# ============================================================================
# AArch64 architecture-specific sources
# ============================================================================
if(ARCH_AARCH64 AND ENABLE_ASM)

    # AArch64 C sources (conditional)
    if(CONFIG_AC3DSP)
        list(APPEND avcodec_sources aarch64/ac3dsp_init_aarch64.c)
    endif()

    if(CONFIG_FDCTDSP)
        list(APPEND avcodec_sources aarch64/fdctdsp_init_aarch64.c)
    endif()

    if(CONFIG_FMTCONVERT)
        list(APPEND avcodec_sources aarch64/fmtconvert_init.c)
    endif()

    if(CONFIG_H264CHROMA)
        list(APPEND avcodec_sources aarch64/h264chroma_init_aarch64.c)
    endif()

    if(CONFIG_H264DSP)
        list(APPEND avcodec_sources aarch64/h264dsp_init_aarch64.c)
    endif()

    if(CONFIG_HUFFYUVDSP)
        list(APPEND avcodec_sources aarch64/huffyuvdsp_init_aarch64.c)
    endif()

    if(CONFIG_H264PRED)
        list(APPEND avcodec_sources aarch64/h264pred_init.c)
    endif()

    if(CONFIG_H264QPEL)
        list(APPEND avcodec_sources aarch64/h264qpel_init_aarch64.c)
    endif()

    if(CONFIG_HPELDSP)
        list(APPEND avcodec_sources aarch64/hpeldsp_init_aarch64.c)
    endif()

    if(CONFIG_IDCTDSP)
        list(APPEND avcodec_sources aarch64/idctdsp_init_aarch64.c)
    endif()

    if(CONFIG_ME_CMP)
        list(APPEND avcodec_sources aarch64/me_cmp_init_aarch64.c)
    endif()

    if(CONFIG_MPEGAUDIODSP)
        list(APPEND avcodec_sources aarch64/mpegaudiodsp_init.c)
    endif()

    if(CONFIG_MPEGVIDEOENCDSP)
        list(APPEND avcodec_sources aarch64/mpegvideoencdsp_init.c)
    endif()

    if(CONFIG_NEON_CLOBBER_TEST)
        list(APPEND avcodec_sources aarch64/neontest.c)
    endif()

    if(CONFIG_PIXBLOCKDSP)
        list(APPEND avcodec_sources aarch64/pixblockdsp_init_aarch64.c)
    endif()

    if(CONFIG_PNG_DECODER)
        list(APPEND avcodec_sources aarch64/pngdsp_init.c)
    endif()

    if(CONFIG_VIDEODSP)
        list(APPEND avcodec_sources aarch64/videodsp_init.c)
    endif()

    if(CONFIG_VP8DSP)
        list(APPEND avcodec_sources aarch64/vp8dsp_init_aarch64.c)
    endif()

    if(CONFIG_AAC_DECODER)
        list(APPEND avcodec_sources aarch64/aacpsdsp_init_aarch64.c)
        list(APPEND avcodec_sources aarch64/sbrdsp_init_aarch64.c)
    endif()

    if(CONFIG_AAC_ENCODER)
        list(APPEND avcodec_sources aarch64/aacencdsp_init.c)
    endif()

    if(CONFIG_DCA_DECODER)
        list(APPEND avcodec_sources aarch64/synth_filter_init.c)
    endif()

    if(CONFIG_OPUS_DECODER)
        list(APPEND avcodec_sources aarch64/opusdsp_init.c)
    endif()

    if(CONFIG_RV40_DECODER)
        list(APPEND avcodec_sources aarch64/rv40dsp_init_aarch64.c)
    endif()

    if(CONFIG_VC1DSP)
        list(APPEND avcodec_sources aarch64/vc1dsp_init_aarch64.c)
    endif()

    if(CONFIG_VORBIS_DECODER)
        list(APPEND avcodec_sources aarch64/vorbisdsp_init.c)
    endif()

    if(CONFIG_VP9_DECODER)
        list(APPEND avcodec_sources aarch64/vp9dsp_init_10bpp_aarch64.c)
        list(APPEND avcodec_sources aarch64/vp9dsp_init_12bpp_aarch64.c)
        list(APPEND avcodec_sources aarch64/vp9mc_aarch64.S)
        list(APPEND avcodec_sources aarch64/vp9dsp_init_aarch64.c)
    endif()

    if(CONFIG_VVC_DECODER)
        list(APPEND avcodec_sources aarch64/vvc/dsp_init.c)
    endif()

    # ARMv8 sources
    if(CONFIG_VIDEODSP)
        list(APPEND avcodec_sources aarch64/videodsp.S)
    endif()

    if(HAVE_NEON)
        # NEON sources (conditional)
        if(CONFIG_AAC_DECODER)
            list(APPEND avcodec_sources aarch64/sbrdsp_neon.S)
            list(APPEND avcodec_sources aarch64/aacpsdsp_neon.S)
        endif()

        if(CONFIG_AAC_ENCODER)
            list(APPEND avcodec_sources aarch64/aacencdsp_neon.S)
        endif()

        if(CONFIG_AC3DSP)
            list(APPEND avcodec_sources aarch64/ac3dsp_neon.S)
        endif()

        if(CONFIG_FDCTDSP)
            list(APPEND avcodec_sources aarch64/fdctdsp_neon.S)
        endif()

        if(CONFIG_FMTCONVERT)
            list(APPEND avcodec_sources aarch64/fmtconvert_neon.S)
        endif()

        if(CONFIG_H264CHROMA)
            list(APPEND avcodec_sources aarch64/h264cmc_neon.S)
        endif()

        if(CONFIG_H264DSP)
            list(APPEND avcodec_sources aarch64/h264dsp_neon.S)
            list(APPEND avcodec_sources aarch64/h264idct_neon.S)
        endif()

        if(CONFIG_H264PRED)
            list(APPEND avcodec_sources aarch64/h264pred_neon.S)
        endif()

        if(CONFIG_H264QPEL)
            list(APPEND avcodec_sources aarch64/h264qpel_neon.S)
            list(APPEND avcodec_sources aarch64/hpeldsp_neon.S)
        endif()

        if(CONFIG_HPELDSP)
            list(APPEND avcodec_sources aarch64/hpeldsp_neon.S)
        endif()

        if(CONFIG_HUFFYUVDSP)
            list(APPEND avcodec_sources aarch64/huffyuvdsp_neon.S)
        endif()

        if(CONFIG_IDCTDSP)
            list(APPEND avcodec_sources aarch64/idctdsp_neon.S)
            list(APPEND avcodec_sources aarch64/simple_idct_neon.S)
        endif()

        if(CONFIG_ME_CMP)
            list(APPEND avcodec_sources aarch64/me_cmp_neon.S)
        endif()

        if(CONFIG_MPEGAUDIODSP)
            list(APPEND avcodec_sources aarch64/mpegaudiodsp_neon.S)
        endif()

        if(CONFIG_MPEGVIDEOENCDSP)
            list(APPEND avcodec_sources aarch64/mpegvideoencdsp_neon.S)
        endif()

        if(CONFIG_PIXBLOCKDSP)
            list(APPEND avcodec_sources aarch64/pixblockdsp_neon.S)
        endif()

        if(CONFIG_PNG_DECODER)
            list(APPEND avcodec_sources aarch64/pngdsp_neon.S)
        endif()

        if(CONFIG_VC1DSP)
            list(APPEND avcodec_sources aarch64/vc1dsp_neon.S)
        endif()

        if(CONFIG_VP8DSP)
            list(APPEND avcodec_sources aarch64/vp8dsp_neon.S)
        endif()

        if(CONFIG_DCA_DECODER)
            list(APPEND avcodec_sources aarch64/synth_filter_neon.S)
        endif()

        if(CONFIG_OPUS_DECODER)
            list(APPEND avcodec_sources aarch64/opusdsp_neon.S)
        endif()

        if(CONFIG_VORBIS_DECODER)
            list(APPEND avcodec_sources aarch64/vorbisdsp_neon.S)
        endif()

        if(CONFIG_VP9_DECODER)
            list(APPEND avcodec_sources aarch64/vp9itxfm_16bpp_neon.S)
            list(APPEND avcodec_sources aarch64/vp9itxfm_neon.S)
            list(APPEND avcodec_sources aarch64/vp9lpf_16bpp_neon.S)
            list(APPEND avcodec_sources aarch64/vp9lpf_neon.S)
            list(APPEND avcodec_sources aarch64/vp9mc_16bpp_neon.S)
            list(APPEND avcodec_sources aarch64/vp9mc_neon.S)
        endif()

        if(CONFIG_HEVC_DECODER)
            list(APPEND avcodec_sources aarch64/hevcdsp_deblock_neon.S)
            list(APPEND avcodec_sources aarch64/hevcdsp_dequant_neon.S)
            list(APPEND avcodec_sources aarch64/hevcdsp_idct_neon.S)
            list(APPEND avcodec_sources aarch64/hevcdsp_init_aarch64.c)
            list(APPEND avcodec_sources aarch64/h26x/epel_neon.S)
            list(APPEND avcodec_sources aarch64/h26x/qpel_neon.S)
            list(APPEND avcodec_sources aarch64/h26x/sao_neon.S)
        endif()

        if(CONFIG_VVC_DECODER)
            list(APPEND avcodec_sources aarch64/vvc/alf.S)
            list(APPEND avcodec_sources aarch64/vvc/inter.S)
            list(APPEND avcodec_sources aarch64/vvc/sad.S)
            list(APPEND avcodec_sources aarch64/h26x/epel_neon.S)
            list(APPEND avcodec_sources aarch64/h26x/qpel_neon.S)
            list(APPEND avcodec_sources aarch64/h26x/sao_neon.S)
        endif()

    endif()

    if(HAVE_SME2)
        # SME2 sources (conditional)
        if(CONFIG_VVC_DECODER)
            list(APPEND avcodec_sources aarch64/vvc/inter_sme2.S)
        endif()

    endif()

    if(HAVE_NEON)
        # neon/ subdirectory C helper files
        list(APPEND avcodec_sources neon/mpegvideo.c)
    endif()

endif()

# ============================================================================
# Thread support (from OBJS-$(HAVE_THREADS) in Makefile)
# ============================================================================
if(HAVE_THREADS)
    list(APPEND avcodec_sources pthread.c pthread_slice.c pthread_frame.c)
endif()
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
# Generate custom codec_list.c and bsf_list.c based on actually compiled files
# Strategy: scan allcodecs.c for all extern declarations, then filter by
# checking which symbols are actually defined in compiled source files.
# This handles codecs defined via macros (like PCM codecs in pcm.c).
# ============================================================================

# Tablegen files (generate lookup tables, not compiled into library)
set(avcodec_tablegen_files
    aacps_fixed_tablegen.c
    aacps_tablegen.c
    aacps_tablegen_template.c
    cbrt_fixed_tablegen.c
    cbrt_tablegen.c
    cbrt_tablegen_template.c
    dv_tablegen.c
    motionpixels_tablegen.c
    mpegaudio_tablegen.c
    mpegaudiodec_common_tablegen.c
    pcm_tablegen.c
    qdm2_tablegen.c
    sinewin_fixed_tablegen.c
    sinewin_tablegen.c
)

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
    dirac_dwt_template.c
    ffv1_template.c
    ffv1dec_template.c
    ffv1enc_template.c
    flacdsp_lpc_template.c
    flacdsp_template.c
    g728_template.c
    gsmdec_template.c
    h264_mb_template.c
    h264_mc_template.c
    h264addpx_template.c
    h264chroma_template.c
    h264dsp_template.c
    h264idct_template.c
    h264pred_template.c
    h264qpel_template.c
    hpel_template.c
    jfdctint_template.c
    motion_est_template.c
    mpegaudiodec_template.c
    mpegaudiodsp_template.c
    pel_template.c
    qpel_template.c
    sbrdsp_template.c
    simple_idct_template.c
    texturedsp_template.c
    v210_template.c
    videodsp_template.c
    vp9_mc_template.c
    vp9dsp_template.c
)

# Files requiring external libraries not available by default
set(avcodec_external_lib_files
    amfdec.c
    amfenc.c
    amfenc_av1.c
    amfenc_h264.c
    amfenc_hevc.c
    audiotoolboxdec.c
    audiotoolboxenc.c
    cuviddec.c
    d3d11va.c
    d3d12va_av1.c
    d3d12va_decode.c
    d3d12va_encode.c
    d3d12va_encode_av1.c
    d3d12va_encode_h264.c
    d3d12va_encode_hevc.c
    d3d12va_h264.c
    d3d12va_hevc.c
    d3d12va_mpeg2.c
    d3d12va_vc1.c
    d3d12va_vp9.c
    dxva2.c
    dxva2_av1.c
    dxva2_h264.c
    dxva2_hevc.c
    dxva2_mpeg2.c
    dxva2_vc1.c
    dxva2_vp9.c
    ffjni.c
    fflcms2.c
    ffv1_vulkan.c
    ffv1enc_vulkan.c
    lcevcdec.c
    libaom.c
    libaomdec.c
    libaomenc.c
    libcelt_dec.c
    libcodec2.c
    libdav1d.c
    libfdk-aacdec.c
    libfdk-aacenc.c
    libgsmdec.c
    libgsmenc.c
    libjxl.c
    libjxldec.c
    libjxlenc.c
    libkvazaar.c
    libmp3lame.c
    libopencore-amr.c
    libopenh264.c
    libopenh264dec.c
    libopenh264enc.c
    libopenjpegenc.c
    libopus.c
    libopusdec.c
    libopusenc.c
    librav1e.c
    libshine.c
    libspeexdec.c
    libspeexenc.c
    libsvtav1.c
    libtheoraenc.c
    libtwolame.c
    libuavs3d.c
    libvorbisdec.c
    libvorbisenc.c
    libvpxdec.c
    libvpxenc.c
    libvvenc.c
    libwebpenc.c
    libwebpenc_animencoder.c
    libwebpenc_common.c
    libx264.c
    libx265.c
    libxavs.c
    libxavs2.c
    libxevd.c
    libxeve.c
    mediacodec.c
    mediacodec_surface.c
    mediacodec_sw_buffer.c
    mediacodec_wrapper.c
    mediacodecdec.c
    mediacodecdec_common.c
    mediacodecenc.c
    mf_utils.c
    mfenc.c
    mmaldec.c
    nvdec.c
    nvdec_av1.c
    nvdec_h264.c
    nvdec_hevc.c
    nvdec_mjpeg.c
    nvdec_mpeg12.c
    nvdec_mpeg4.c
    nvdec_vc1.c
    nvdec_vp8.c
    nvdec_vp9.c
    nvenc.c
    nvenc_av1.c
    nvenc_h264.c
    nvenc_hevc.c
    ohcodec.c
    ohdec.c
    ohenc.c
    omx.c
    proresenc_kostya_vulkan.c
    qsv.c
    qsv_api.c
    qsvdec.c
    qsvenc.c
    qsvenc_av1.c
    qsvenc_h264.c
    qsvenc_hevc.c
    qsvenc_jpeg.c
    qsvenc_mpeg2.c
    qsvenc_vp9.c
    rkmppdec.c
    rkmppenc.c
    v4l2_buffers.c
    v4l2_context.c
    v4l2_fmt.c
    v4l2_m2m.c
    v4l2_m2m_dec.c
    v4l2_m2m_enc.c
    vaapi_av1.c
    vaapi_decode.c
    vaapi_encode.c
    vaapi_encode_av1.c
    vaapi_encode_h264.c
    vaapi_encode_h265.c
    vaapi_encode_mjpeg.c
    vaapi_encode_mpeg2.c
    vaapi_encode_vp8.c
    vaapi_encode_vp9.c
    vaapi_h264.c
    vaapi_hevc.c
    vaapi_mjpeg.c
    vaapi_mpeg2.c
    vaapi_mpeg4.c
    vaapi_vc1.c
    vaapi_vp8.c
    vaapi_vp9.c
    vaapi_vvc.c
    vdpau.c
    vdpau_av1.c
    vdpau_h264.c
    vdpau_hevc.c
    vdpau_mpeg12.c
    vdpau_mpeg4.c
    vdpau_vc1.c
    vdpau_vp9.c
    videotoolbox.c
    videotoolbox_av1.c
    videotoolbox_vp9.c
    videotoolboxenc.c
    vulkan.c
    vulkan_av1.c
    vulkan_decode.c
    vulkan_dpx.c
    vulkan_encode.c
    vulkan_encode_av1.c
    vulkan_encode_h264.c
    vulkan_encode_h265.c
    vulkan_ffv1.c
    vulkan_h264.c
    vulkan_hevc.c
    vulkan_prores.c
    vulkan_prores_raw.c
    vulkan_video.c
    vulkan_vp9.c
)

# Combine all excluded files
# allcodecs.c is excluded because it references ALL codecs (including hardware-accelerated ones
# that are not compiled). It is replaced by the generated allcodecs_generated.c below.
set(avcodec_auto_excluded ${avcodec_template_files} ${avcodec_external_lib_files} ${avcodec_tablegen_files}
    allcodecs.c)

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
set(_excluded_codec_syms "")
set(_excluded_bsf_syms "")
foreach(_excl_name IN LISTS avcodec_auto_excluded)
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
# Copy the runtime functions from allcodecs.c
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

# ============================================================================
# Build target
# ============================================================================

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
