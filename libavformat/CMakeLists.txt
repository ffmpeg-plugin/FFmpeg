# libavformat CMakeLists.txt
# Generated from libavformat/Makefile by tools/gen_avformat_cmake.py
# All source files are listed explicitly (no file(GLOB) usage).

# ============================================================================
# Core sources (unconditional, from OBJS = in Makefile)
# ============================================================================
set(avformat_sources
    allformats.c
    av1.c
    avformat.c
    avio.c
    aviobuf.c
    codecstring.c
    demux.c
    demux_utils.c
    dump.c
    dv.c
    format.c
    id3v1.c
    id3v2.c
    isom_tags.c
    lcevc.c
    metadata.c
    mux.c
    mux_utils.c
    nal.c
    options.c
    os_support.c
    protocols.c
    riff.c
    sdp.c
    seek.c
    url.c
    urldecode.c
    utils.c
    version.c
    vpcc.c
)

# ============================================================================
# Conditional sources based on CONFIG_* variables
# (from OBJS-$(CONFIG_*) in Makefile)
# ============================================================================

# --- Subsystems and helpers ---
if(CONFIG_ISO_MEDIA)
    list(APPEND avformat_sources isom.c)
endif()

if(CONFIG_ISO_WRITER)
    list(APPEND avformat_sources avc.c)
    list(APPEND avformat_sources hevc.c)
    list(APPEND avformat_sources vvc.c)
endif()

if(CONFIG_IAMFDEC)
    list(APPEND avformat_sources iamf_reader.c)
    list(APPEND avformat_sources iamf_parse.c)
    list(APPEND avformat_sources iamf.c)
endif()

if(CONFIG_IAMFENC)
    list(APPEND avformat_sources iamf_writer.c)
    list(APPEND avformat_sources iamf.c)
endif()

if(CONFIG_NETWORK)
    list(APPEND avformat_sources network.c)
endif()

if(CONFIG_RIFFDEC)
    list(APPEND avformat_sources riffdec.c)
endif()

if(CONFIG_RIFFENC)
    list(APPEND avformat_sources riffenc.c)
endif()

if(CONFIG_RTPDEC)
    list(APPEND avformat_sources rdt.c)
    list(APPEND avformat_sources rtp.c)
    list(APPEND avformat_sources rtpdec.c)
    list(APPEND avformat_sources rtpdec_ac3.c)
    list(APPEND avformat_sources rtpdec_amr.c)
    list(APPEND avformat_sources rtpdec_asf.c)
    list(APPEND avformat_sources rtpdec_av1.c)
    list(APPEND avformat_sources rtpdec_dv.c)
    list(APPEND avformat_sources rtpdec_g726.c)
    list(APPEND avformat_sources rtpdec_h261.c)
    list(APPEND avformat_sources rtpdec_h263.c)
    list(APPEND avformat_sources rtpdec_h263_rfc2190.c)
    list(APPEND avformat_sources rtpdec_h264.c)
    list(APPEND avformat_sources rtpdec_hevc.c)
    list(APPEND avformat_sources rtpdec_ilbc.c)
    list(APPEND avformat_sources rtpdec_jpeg.c)
    list(APPEND avformat_sources rtpdec_latm.c)
    list(APPEND avformat_sources rtpdec_mpa_robust.c)
    list(APPEND avformat_sources rtpdec_mpeg12.c)
    list(APPEND avformat_sources rtpdec_mpeg4.c)
    list(APPEND avformat_sources rtpdec_mpegts.c)
    list(APPEND avformat_sources rtpdec_opus.c)
    list(APPEND avformat_sources rtpdec_qcelp.c)
    list(APPEND avformat_sources rtpdec_qdm2.c)
    list(APPEND avformat_sources rtpdec_qt.c)
    list(APPEND avformat_sources rtpdec_rfc4175.c)
    list(APPEND avformat_sources rtpdec_svq3.c)
    list(APPEND avformat_sources rtpdec_vc2hq.c)
    list(APPEND avformat_sources rtpdec_vp8.c)
    list(APPEND avformat_sources rtpdec_vp9.c)
    list(APPEND avformat_sources rtpdec_xiph.c)
endif()

if(CONFIG_RTPENC_CHAIN)
    list(APPEND avformat_sources rtpenc_chain.c)
    list(APPEND avformat_sources rtp.c)
endif()

if(CONFIG_SRTP)
    list(APPEND avformat_sources srtp.c)
endif()

# --- Muxers ---
if(CONFIG_A64_MUXER)
    list(APPEND avformat_sources a64.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_AC3_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_AC4_MUXER)
    list(APPEND avformat_sources ac4enc.c)
endif()

if(CONFIG_ADTS_MUXER)
    list(APPEND avformat_sources adtsenc.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
    list(APPEND avformat_sources id3v2enc.c)
endif()

if(CONFIG_ADX_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_AEA_MUXER)
    list(APPEND avformat_sources aeaenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_AIFF_MUXER)
    list(APPEND avformat_sources aiffenc.c)
    list(APPEND avformat_sources aiff.c)
    list(APPEND avformat_sources id3v2enc.c)
endif()

if(CONFIG_ALP_MUXER)
    list(APPEND avformat_sources alp.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_AMR_MUXER)
    list(APPEND avformat_sources amr.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_AMV_MUXER)
    list(APPEND avformat_sources amvenc.c)
endif()

if(CONFIG_APM_MUXER)
    list(APPEND avformat_sources apm.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_APNG_MUXER)
    list(APPEND avformat_sources apngenc.c)
endif()

if(CONFIG_APTX_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_APTX_HD_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_APV_MUXER)
    list(APPEND avformat_sources apvenc.c)
endif()

if(CONFIG_ARGO_ASF_MUXER)
    list(APPEND avformat_sources argo_asf.c)
endif()

if(CONFIG_ARGO_CVG_MUXER)
    list(APPEND avformat_sources argo_cvg.c)
endif()

if(CONFIG_ASF_MUXER)
    list(APPEND avformat_sources asfenc.c)
    list(APPEND avformat_sources asf.c)
    list(APPEND avformat_sources asf_tags.c)
    list(APPEND avformat_sources avlanguage.c)
endif()

if(CONFIG_ASS_MUXER)
    list(APPEND avformat_sources assenc.c)
endif()

if(CONFIG_AST_MUXER)
    list(APPEND avformat_sources ast.c)
    list(APPEND avformat_sources astenc.c)
endif()

if(CONFIG_AU_MUXER)
    list(APPEND avformat_sources au.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_AVI_MUXER)
    list(APPEND avformat_sources avienc.c)
    list(APPEND avformat_sources mpegtsenc.c)
    list(APPEND avformat_sources avlanguage.c)
    list(APPEND avformat_sources rawutils.c)
endif()

if(CONFIG_AVM2_MUXER)
    list(APPEND avformat_sources swfenc.c)
    list(APPEND avformat_sources swf.c)
endif()

if(CONFIG_AVS2_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_AVS3_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_BIT_MUXER)
    list(APPEND avformat_sources bit.c)
endif()

if(CONFIG_CAF_MUXER)
    list(APPEND avformat_sources cafenc.c)
    list(APPEND avformat_sources caf.c)
    list(APPEND avformat_sources riff.c)
endif()

if(CONFIG_CAVSVIDEO_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_CODEC2_MUXER)
    list(APPEND avformat_sources codec2.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_CODEC2RAW_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_CRC_MUXER)
    list(APPEND avformat_sources crcenc.c)
endif()

if(CONFIG_DATA_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_DASH_MUXER)
    list(APPEND avformat_sources dash.c)
    list(APPEND avformat_sources dashenc.c)
    list(APPEND avformat_sources hlsplaylist.c)
endif()

if(CONFIG_DAUD_MUXER)
    list(APPEND avformat_sources daudenc.c)
endif()

if(CONFIG_DFPWM_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_DIRAC_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_DNXHD_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_DTS_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_DV_MUXER)
    list(APPEND avformat_sources dvenc.c)
endif()

if(CONFIG_EAC3_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_FFMETADATA_MUXER)
    list(APPEND avformat_sources ffmetaenc.c)
endif()

if(CONFIG_FIFO_MUXER)
    list(APPEND avformat_sources fifo.c)
endif()

if(CONFIG_FILMSTRIP_MUXER)
    list(APPEND avformat_sources filmstripenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_FITS_MUXER)
    list(APPEND avformat_sources fitsenc.c)
endif()

if(CONFIG_FLAC_MUXER)
    list(APPEND avformat_sources flacenc.c)
    list(APPEND avformat_sources flacenc_header.c)
    list(APPEND avformat_sources vorbiscomment.c)
endif()

if(CONFIG_FLV_MUXER)
    list(APPEND avformat_sources flvenc.c)
endif()

if(CONFIG_FRAMECRC_MUXER)
    list(APPEND avformat_sources framecrcenc.c)
    list(APPEND avformat_sources framehash.c)
endif()

if(CONFIG_FRAMEHASH_MUXER)
    list(APPEND avformat_sources hashenc.c)
    list(APPEND avformat_sources framehash.c)
endif()

if(CONFIG_FRAMEMD5_MUXER)
    list(APPEND avformat_sources hashenc.c)
    list(APPEND avformat_sources framehash.c)
endif()

if(CONFIG_GIF_MUXER)
    list(APPEND avformat_sources gif.c)
endif()

if(CONFIG_GSM_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_GXF_MUXER)
    list(APPEND avformat_sources gxfenc.c)
endif()

if(CONFIG_G722_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_G723_1_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_G726_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_G726LE_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_H261_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_H263_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_H264_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_HASH_MUXER)
    list(APPEND avformat_sources hashenc.c)
endif()

if(CONFIG_HDS_MUXER)
    list(APPEND avformat_sources hdsenc.c)
endif()

if(CONFIG_HEVC_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_EVC_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_HLS_MUXER)
    list(APPEND avformat_sources hlsenc.c)
    list(APPEND avformat_sources hlsplaylist.c)
endif()

if(CONFIG_IAMF_MUXER)
    list(APPEND avformat_sources iamfenc.c)
endif()

if(CONFIG_ICO_MUXER)
    list(APPEND avformat_sources icoenc.c)
endif()

if(CONFIG_ILBC_MUXER)
    list(APPEND avformat_sources ilbc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_IMAGE2_MUXER)
    list(APPEND avformat_sources img2enc.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE2PIPE_MUXER)
    list(APPEND avformat_sources img2enc.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IRCAM_MUXER)
    list(APPEND avformat_sources ircamenc.c)
    list(APPEND avformat_sources ircam.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_IVF_MUXER)
    list(APPEND avformat_sources ivfenc.c)
endif()

if(CONFIG_JACOSUB_MUXER)
    list(APPEND avformat_sources jacosubenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_KVAG_MUXER)
    list(APPEND avformat_sources kvag.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_LATM_MUXER)
    list(APPEND avformat_sources latmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_LC3_MUXER)
    list(APPEND avformat_sources lc3.c)
endif()

if(CONFIG_LRC_MUXER)
    list(APPEND avformat_sources lrcenc.c)
    list(APPEND avformat_sources lrc.c)
endif()

if(CONFIG_M4V_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_MATROSKA_MUXER)
    list(APPEND avformat_sources matroskaenc.c)
    list(APPEND avformat_sources matroska.c)
    list(APPEND avformat_sources flacenc_header.c)
    list(APPEND avformat_sources avlanguage.c)
    list(APPEND avformat_sources vorbiscomment.c)
    list(APPEND avformat_sources wv.c)
    list(APPEND avformat_sources dovi_isom.c)
endif()

if(CONFIG_MCC_MUXER)
    list(APPEND avformat_sources mccenc.c)
endif()

if(CONFIG_MD5_MUXER)
    list(APPEND avformat_sources hashenc.c)
endif()

if(CONFIG_MICRODVD_MUXER)
    list(APPEND avformat_sources microdvdenc.c)
endif()

if(CONFIG_MJPEG_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_MLP_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_MMF_MUXER)
    list(APPEND avformat_sources mmf.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_MOV_MUXER)
    list(APPEND avformat_sources movenc.c)
    list(APPEND avformat_sources movenchint.c)
    list(APPEND avformat_sources mov_chan.c)
    list(APPEND avformat_sources rtp.c)
    list(APPEND avformat_sources movenccenc.c)
    list(APPEND avformat_sources movenc_ttml.c)
    list(APPEND avformat_sources rawutils.c)
    list(APPEND avformat_sources apv.c)
    list(APPEND avformat_sources dovi_isom.c)
    list(APPEND avformat_sources evc.c)
    list(APPEND avformat_sources cbs.c)
    list(APPEND avformat_sources cbs_av1.c)
    list(APPEND avformat_sources cbs_apv.c)
endif()

if(CONFIG_MP2_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_MP3_MUXER)
    list(APPEND avformat_sources mp3enc.c)
    list(APPEND avformat_sources rawenc.c)
    list(APPEND avformat_sources id3v2enc.c)
endif()

if(CONFIG_MPEG1SYSTEM_MUXER)
    list(APPEND avformat_sources mpegenc.c)
endif()

if(CONFIG_MPEG1VCD_MUXER)
    list(APPEND avformat_sources mpegenc.c)
endif()

if(CONFIG_MPEG1VIDEO_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_MPEG2DVD_MUXER)
    list(APPEND avformat_sources mpegenc.c)
endif()

if(CONFIG_MPEG2SVCD_MUXER)
    list(APPEND avformat_sources mpegenc.c)
endif()

if(CONFIG_MPEG2VIDEO_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_MPEG2VOB_MUXER)
    list(APPEND avformat_sources mpegenc.c)
endif()

if(CONFIG_MPEGTS_MUXER)
    list(APPEND avformat_sources mpegtsenc.c)
endif()

if(CONFIG_MPJPEG_MUXER)
    list(APPEND avformat_sources mpjpeg.c)
endif()

if(CONFIG_MXF_MUXER)
    list(APPEND avformat_sources mxfenc.c)
    list(APPEND avformat_sources mxf.c)
endif()

if(CONFIG_NULL_MUXER)
    list(APPEND avformat_sources nullenc.c)
endif()

if(CONFIG_NUT_MUXER)
    list(APPEND avformat_sources nutenc.c)
    list(APPEND avformat_sources nut.c)
endif()

if(CONFIG_OBU_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_OGA_MUXER)
    list(APPEND avformat_sources oggenc.c)
    list(APPEND avformat_sources vorbiscomment.c)
endif()

if(CONFIG_OGG_MUXER)
    list(APPEND avformat_sources oggenc.c)
    list(APPEND avformat_sources vorbiscomment.c)
endif()

if(CONFIG_OGV_MUXER)
    list(APPEND avformat_sources oggenc.c)
    list(APPEND avformat_sources vorbiscomment.c)
endif()

if(CONFIG_OMA_MUXER)
    list(APPEND avformat_sources omaenc.c)
    list(APPEND avformat_sources rawenc.c)
    list(APPEND avformat_sources oma.c)
    list(APPEND avformat_sources id3v2enc.c)
endif()

if(CONFIG_OPUS_MUXER)
    list(APPEND avformat_sources oggenc.c)
    list(APPEND avformat_sources vorbiscomment.c)
endif()

if(CONFIG_PCM_ALAW_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_F32BE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_F32LE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_F64BE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_F64LE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_MULAW_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_S16BE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_S16LE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_S24BE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_S24LE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_S32BE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_S32LE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_S8_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_U16BE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_U16LE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_U24BE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_U24LE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_U32BE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_U32LE_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_U8_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_PCM_VIDC_MUXER)
    list(APPEND avformat_sources pcmenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_RAWVIDEO_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_RCWT_MUXER)
    list(APPEND avformat_sources rcwtenc.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_RM_MUXER)
    list(APPEND avformat_sources rmenc.c)
    list(APPEND avformat_sources rm.c)
endif()

if(CONFIG_ROQ_MUXER)
    list(APPEND avformat_sources idroqenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_RSO_MUXER)
    list(APPEND avformat_sources rsoenc.c)
    list(APPEND avformat_sources rso.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_RTP_MPEGTS_MUXER)
    list(APPEND avformat_sources rtpenc_mpegts.c)
endif()

if(CONFIG_RTP_MUXER)
    list(APPEND avformat_sources rtp.c)
    list(APPEND avformat_sources rtpenc_aac.c)
    list(APPEND avformat_sources rtpenc_latm.c)
    list(APPEND avformat_sources rtpenc_amr.c)
    list(APPEND avformat_sources rtpenc_av1.c)
    list(APPEND avformat_sources rtpenc_h261.c)
    list(APPEND avformat_sources rtpenc_h263.c)
    list(APPEND avformat_sources rtpenc_h263_rfc2190.c)
    list(APPEND avformat_sources rtpenc_h264_hevc.c)
    list(APPEND avformat_sources rtpenc_jpeg.c)
    list(APPEND avformat_sources rtpenc_mpv.c)
    list(APPEND avformat_sources rtpenc.c)
    list(APPEND avformat_sources rtpenc_rfc4175.c)
    list(APPEND avformat_sources rtpenc_vc2hq.c)
    list(APPEND avformat_sources rtpenc_vp8.c)
    list(APPEND avformat_sources rtpenc_vp9.c)
    list(APPEND avformat_sources rtpenc_xiph.c)
endif()

if(CONFIG_RTSP_MUXER)
    list(APPEND avformat_sources rtsp.c)
    list(APPEND avformat_sources rtspenc.c)
    list(APPEND avformat_sources httpauth.c)
endif()

if(CONFIG_SAP_MUXER)
    list(APPEND avformat_sources sapenc.c)
endif()

if(CONFIG_SBC_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_SCC_MUXER)
    list(APPEND avformat_sources sccenc.c)
endif()

if(CONFIG_SEGAFILM_MUXER)
    list(APPEND avformat_sources segafilmenc.c)
endif()

if(CONFIG_SEGMENT_MUXER)
    list(APPEND avformat_sources segment.c)
endif()

if(CONFIG_SMJPEG_MUXER)
    list(APPEND avformat_sources smjpegenc.c)
    list(APPEND avformat_sources smjpeg.c)
endif()

if(CONFIG_SMOOTHSTREAMING_MUXER)
    list(APPEND avformat_sources smoothstreamingenc.c)
endif()

if(CONFIG_SOX_MUXER)
    list(APPEND avformat_sources soxenc.c)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_SPDIF_MUXER)
    list(APPEND avformat_sources spdif.c)
    list(APPEND avformat_sources spdifenc.c)
endif()

if(CONFIG_SPEEX_MUXER)
    list(APPEND avformat_sources oggenc.c)
    list(APPEND avformat_sources vorbiscomment.c)
endif()

if(CONFIG_SRT_MUXER)
    list(APPEND avformat_sources srtenc.c)
endif()

if(CONFIG_STREAMHASH_MUXER)
    list(APPEND avformat_sources hashenc.c)
endif()

if(CONFIG_STREAM_SEGMENT_MUXER)
    list(APPEND avformat_sources segment.c)
endif()

if(CONFIG_SUP_MUXER)
    list(APPEND avformat_sources supenc.c)
endif()

if(CONFIG_SWF_MUXER)
    list(APPEND avformat_sources swfenc.c)
    list(APPEND avformat_sources swf.c)
endif()

if(CONFIG_TEE_MUXER)
    list(APPEND avformat_sources tee.c)
    list(APPEND avformat_sources tee_common.c)
endif()

if(CONFIG_MKVTIMESTAMP_V2_MUXER)
    list(APPEND avformat_sources mkvtimestamp_v2.c)
endif()

if(CONFIG_TRUEHD_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_TTA_MUXER)
    list(APPEND avformat_sources ttaenc.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_TTML_MUXER)
    list(APPEND avformat_sources ttmlenc.c)
endif()

if(CONFIG_UNCODEDFRAMECRC_MUXER)
    list(APPEND avformat_sources uncodedframecrcenc.c)
    list(APPEND avformat_sources framehash.c)
endif()

if(CONFIG_VC1_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_VC1T_MUXER)
    list(APPEND avformat_sources vc1testenc.c)
endif()

if(CONFIG_VOC_MUXER)
    list(APPEND avformat_sources vocenc.c)
    list(APPEND avformat_sources voc.c)
endif()

if(CONFIG_VVC_MUXER)
    list(APPEND avformat_sources rawenc.c)
endif()

if(CONFIG_W64_MUXER)
    list(APPEND avformat_sources wavenc.c)
    list(APPEND avformat_sources w64.c)
endif()

if(CONFIG_WAV_MUXER)
    list(APPEND avformat_sources wavenc.c)
endif()

if(CONFIG_WEBM_MUXER)
    list(APPEND avformat_sources matroskaenc.c)
    list(APPEND avformat_sources matroska.c)
    list(APPEND avformat_sources avlanguage.c)
endif()

if(CONFIG_WEBM_DASH_MANIFEST_MUXER)
    list(APPEND avformat_sources webmdashenc.c)
endif()

if(CONFIG_WEBM_CHUNK_MUXER)
    list(APPEND avformat_sources webm_chunk.c)
endif()

if(CONFIG_WEBP_MUXER)
    list(APPEND avformat_sources webpenc.c)
endif()

if(CONFIG_WEBVTT_MUXER)
    list(APPEND avformat_sources webvttenc.c)
endif()

if(CONFIG_WHIP_MUXER)
    list(APPEND avformat_sources whip.c)
    list(APPEND avformat_sources avc.c)
    list(APPEND avformat_sources http.c)
    list(APPEND avformat_sources srtp.c)
endif()

if(CONFIG_WSAUD_MUXER)
    list(APPEND avformat_sources westwood_audenc.c)
endif()

if(CONFIG_WTV_MUXER)
    list(APPEND avformat_sources wtvenc.c)
    list(APPEND avformat_sources wtv_common.c)
    list(APPEND avformat_sources asf.c)
endif()

if(CONFIG_WV_MUXER)
    list(APPEND avformat_sources wvenc.c)
    list(APPEND avformat_sources wv.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_YUV4MPEGPIPE_MUXER)
    list(APPEND avformat_sources yuv4mpegenc.c)
endif()

if(CONFIG_CHROMAPRINT_MUXER)
    list(APPEND avformat_sources chromaprint.c)
endif()

# --- Demuxers ---
if(CONFIG_AA_DEMUXER)
    list(APPEND avformat_sources aadec.c)
endif()

if(CONFIG_AAC_DEMUXER)
    list(APPEND avformat_sources aacdec.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_AAX_DEMUXER)
    list(APPEND avformat_sources aaxdec.c)
endif()

if(CONFIG_AC3_DEMUXER)
    list(APPEND avformat_sources ac3dec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_AC4_DEMUXER)
    list(APPEND avformat_sources ac4dec.c)
endif()

if(CONFIG_ACE_DEMUXER)
    list(APPEND avformat_sources acedec.c)
endif()

if(CONFIG_ACM_DEMUXER)
    list(APPEND avformat_sources acm.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_ACT_DEMUXER)
    list(APPEND avformat_sources act.c)
endif()

if(CONFIG_ADF_DEMUXER)
    list(APPEND avformat_sources bintext.c)
    list(APPEND avformat_sources sauce.c)
endif()

if(CONFIG_ADP_DEMUXER)
    list(APPEND avformat_sources adp.c)
endif()

if(CONFIG_ADS_DEMUXER)
    list(APPEND avformat_sources ads.c)
endif()

if(CONFIG_ADX_DEMUXER)
    list(APPEND avformat_sources adxdec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_AEA_DEMUXER)
    list(APPEND avformat_sources aeadec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_AFC_DEMUXER)
    list(APPEND avformat_sources afc.c)
endif()

if(CONFIG_AIFF_DEMUXER)
    list(APPEND avformat_sources aiffdec.c)
    list(APPEND avformat_sources aiff.c)
    list(APPEND avformat_sources pcm.c)
    list(APPEND avformat_sources mov_chan.c)
    list(APPEND avformat_sources replaygain.c)
endif()

if(CONFIG_AIX_DEMUXER)
    list(APPEND avformat_sources aixdec.c)
endif()

if(CONFIG_ALP_DEMUXER)
    list(APPEND avformat_sources alp.c)
endif()

if(CONFIG_AMR_DEMUXER)
    list(APPEND avformat_sources amr.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_AMRNB_DEMUXER)
    list(APPEND avformat_sources amr.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_AMRWB_DEMUXER)
    list(APPEND avformat_sources amr.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_ANM_DEMUXER)
    list(APPEND avformat_sources anm.c)
endif()

if(CONFIG_APAC_DEMUXER)
    list(APPEND avformat_sources apac.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_APC_DEMUXER)
    list(APPEND avformat_sources apc.c)
endif()

if(CONFIG_APE_DEMUXER)
    list(APPEND avformat_sources ape.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_APM_DEMUXER)
    list(APPEND avformat_sources apm.c)
endif()

if(CONFIG_APNG_DEMUXER)
    list(APPEND avformat_sources apngdec.c)
endif()

if(CONFIG_APTX_DEMUXER)
    list(APPEND avformat_sources aptxdec.c)
endif()

if(CONFIG_APTX_HD_DEMUXER)
    list(APPEND avformat_sources aptxdec.c)
endif()

if(CONFIG_APV_DEMUXER)
    list(APPEND avformat_sources apvdec.c)
endif()

if(CONFIG_AQTITLE_DEMUXER)
    list(APPEND avformat_sources aqtitledec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_ARGO_ASF_DEMUXER)
    list(APPEND avformat_sources argo_asf.c)
endif()

if(CONFIG_ARGO_BRP_DEMUXER)
    list(APPEND avformat_sources argo_brp.c)
    list(APPEND avformat_sources argo_asf.c)
endif()

if(CONFIG_ARGO_CVG_DEMUXER)
    list(APPEND avformat_sources argo_cvg.c)
endif()

if(CONFIG_ASF_DEMUXER)
    list(APPEND avformat_sources asfdec_f.c)
    list(APPEND avformat_sources asf.c)
    list(APPEND avformat_sources asfcrypt.c)
    list(APPEND avformat_sources asf_tags.c)
    list(APPEND avformat_sources avlanguage.c)
endif()

if(CONFIG_ASF_O_DEMUXER)
    list(APPEND avformat_sources asfdec_o.c)
    list(APPEND avformat_sources asf.c)
    list(APPEND avformat_sources asfcrypt.c)
    list(APPEND avformat_sources asf_tags.c)
    list(APPEND avformat_sources avlanguage.c)
endif()

if(CONFIG_ASS_DEMUXER)
    list(APPEND avformat_sources assdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_AST_DEMUXER)
    list(APPEND avformat_sources ast.c)
    list(APPEND avformat_sources astdec.c)
endif()

if(CONFIG_AU_DEMUXER)
    list(APPEND avformat_sources au.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_AVI_DEMUXER)
    list(APPEND avformat_sources avidec.c)
endif()

if(CONFIG_AVR_DEMUXER)
    list(APPEND avformat_sources avr.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_AVS_DEMUXER)
    list(APPEND avformat_sources avs.c)
    list(APPEND avformat_sources voc_packet.c)
    list(APPEND avformat_sources voc.c)
endif()

if(CONFIG_AVS2_DEMUXER)
    list(APPEND avformat_sources avs2dec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_AVS3_DEMUXER)
    list(APPEND avformat_sources avs3dec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_BETHSOFTVID_DEMUXER)
    list(APPEND avformat_sources bethsoftvid.c)
endif()

if(CONFIG_BFI_DEMUXER)
    list(APPEND avformat_sources bfi.c)
endif()

if(CONFIG_BINK_DEMUXER)
    list(APPEND avformat_sources bink.c)
endif()

if(CONFIG_BINKA_DEMUXER)
    list(APPEND avformat_sources binka.c)
endif()

if(CONFIG_BINTEXT_DEMUXER)
    list(APPEND avformat_sources bintext.c)
    list(APPEND avformat_sources sauce.c)
endif()

if(CONFIG_BIT_DEMUXER)
    list(APPEND avformat_sources bit.c)
endif()

if(CONFIG_BITPACKED_DEMUXER)
    list(APPEND avformat_sources rawvideodec.c)
endif()

if(CONFIG_BMV_DEMUXER)
    list(APPEND avformat_sources bmv.c)
endif()

if(CONFIG_BOA_DEMUXER)
    list(APPEND avformat_sources boadec.c)
endif()

if(CONFIG_BONK_DEMUXER)
    list(APPEND avformat_sources bonk.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_BFSTM_DEMUXER)
    list(APPEND avformat_sources brstm.c)
endif()

if(CONFIG_BRSTM_DEMUXER)
    list(APPEND avformat_sources brstm.c)
endif()

if(CONFIG_C93_DEMUXER)
    list(APPEND avformat_sources c93.c)
    list(APPEND avformat_sources voc_packet.c)
    list(APPEND avformat_sources voc.c)
endif()

if(CONFIG_CAF_DEMUXER)
    list(APPEND avformat_sources cafdec.c)
    list(APPEND avformat_sources caf.c)
    list(APPEND avformat_sources mov_chan.c)
    list(APPEND avformat_sources mov_esds.c)
endif()

if(CONFIG_CAVSVIDEO_DEMUXER)
    list(APPEND avformat_sources cavsvideodec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_CDG_DEMUXER)
    list(APPEND avformat_sources cdg.c)
endif()

if(CONFIG_CDXL_DEMUXER)
    list(APPEND avformat_sources cdxl.c)
endif()

if(CONFIG_CINE_DEMUXER)
    list(APPEND avformat_sources cinedec.c)
endif()

if(CONFIG_CODEC2_DEMUXER)
    list(APPEND avformat_sources codec2.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_CODEC2RAW_DEMUXER)
    list(APPEND avformat_sources codec2.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_CONCAT_DEMUXER)
    list(APPEND avformat_sources concatdec.c)
endif()

if(CONFIG_DATA_DEMUXER)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_DASH_DEMUXER)
    list(APPEND avformat_sources dash.c)
    list(APPEND avformat_sources dashdec.c)
endif()

if(CONFIG_DAUD_DEMUXER)
    list(APPEND avformat_sources dauddec.c)
endif()

if(CONFIG_DCSTR_DEMUXER)
    list(APPEND avformat_sources dcstr.c)
endif()

if(CONFIG_DERF_DEMUXER)
    list(APPEND avformat_sources derf.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_DFA_DEMUXER)
    list(APPEND avformat_sources dfa.c)
endif()

if(CONFIG_DFPWM_DEMUXER)
    list(APPEND avformat_sources dfpwmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_DHAV_DEMUXER)
    list(APPEND avformat_sources dhav.c)
endif()

if(CONFIG_DIRAC_DEMUXER)
    list(APPEND avformat_sources diracdec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_DNXHD_DEMUXER)
    list(APPEND avformat_sources dnxhddec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_DSF_DEMUXER)
    list(APPEND avformat_sources dsfdec.c)
endif()

if(CONFIG_DSICIN_DEMUXER)
    list(APPEND avformat_sources dsicin.c)
endif()

if(CONFIG_DSS_DEMUXER)
    list(APPEND avformat_sources dss.c)
endif()

if(CONFIG_DTSHD_DEMUXER)
    list(APPEND avformat_sources dtshddec.c)
endif()

if(CONFIG_DTS_DEMUXER)
    list(APPEND avformat_sources dtsdec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_DVBSUB_DEMUXER)
    list(APPEND avformat_sources dvbsub.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_DVBTXT_DEMUXER)
    list(APPEND avformat_sources dvbtxt.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_DVDVIDEO_DEMUXER)
    list(APPEND avformat_sources dvdvideodec.c)
    list(APPEND avformat_sources dvdclut.c)
endif()

if(CONFIG_DXA_DEMUXER)
    list(APPEND avformat_sources dxa.c)
endif()

if(CONFIG_EA_CDATA_DEMUXER)
    list(APPEND avformat_sources eacdata.c)
endif()

if(CONFIG_EA_DEMUXER)
    list(APPEND avformat_sources electronicarts.c)
endif()

if(CONFIG_EAC3_DEMUXER)
    list(APPEND avformat_sources ac3dec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_EPAF_DEMUXER)
    list(APPEND avformat_sources epafdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_FFMETADATA_DEMUXER)
    list(APPEND avformat_sources ffmetadec.c)
endif()

if(CONFIG_FILMSTRIP_DEMUXER)
    list(APPEND avformat_sources filmstripdec.c)
endif()

if(CONFIG_FITS_DEMUXER)
    list(APPEND avformat_sources fitsdec.c)
endif()

if(CONFIG_FLAC_DEMUXER)
    list(APPEND avformat_sources flacdec.c)
    list(APPEND avformat_sources rawdec.c)
    list(APPEND avformat_sources flac_picture.c)
    list(APPEND avformat_sources oggparsevorbis.c)
    list(APPEND avformat_sources replaygain.c)
    list(APPEND avformat_sources vorbiscomment.c)
endif()

if(CONFIG_FLIC_DEMUXER)
    list(APPEND avformat_sources flic.c)
endif()

if(CONFIG_FLV_DEMUXER)
    list(APPEND avformat_sources flvdec.c)
endif()

if(CONFIG_LIVE_FLV_DEMUXER)
    list(APPEND avformat_sources flvdec.c)
endif()

if(CONFIG_FOURXM_DEMUXER)
    list(APPEND avformat_sources 4xm.c)
endif()

if(CONFIG_FRM_DEMUXER)
    list(APPEND avformat_sources frmdec.c)
endif()

if(CONFIG_FSB_DEMUXER)
    list(APPEND avformat_sources fsb.c)
endif()

if(CONFIG_FWSE_DEMUXER)
    list(APPEND avformat_sources fwse.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_GIF_DEMUXER)
    list(APPEND avformat_sources gifdec.c)
endif()

if(CONFIG_GSM_DEMUXER)
    list(APPEND avformat_sources gsmdec.c)
endif()

if(CONFIG_GXF_DEMUXER)
    list(APPEND avformat_sources gxf.c)
endif()

if(CONFIG_G722_DEMUXER)
    list(APPEND avformat_sources g722.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_G723_1_DEMUXER)
    list(APPEND avformat_sources g723_1.c)
endif()

if(CONFIG_G726_DEMUXER)
    list(APPEND avformat_sources g726.c)
endif()

if(CONFIG_G726LE_DEMUXER)
    list(APPEND avformat_sources g726.c)
endif()

if(CONFIG_G728_DEMUXER)
    list(APPEND avformat_sources g728dec.c)
endif()

if(CONFIG_G729_DEMUXER)
    list(APPEND avformat_sources g729dec.c)
endif()

if(CONFIG_GDV_DEMUXER)
    list(APPEND avformat_sources gdv.c)
endif()

if(CONFIG_GENH_DEMUXER)
    list(APPEND avformat_sources genh.c)
endif()

if(CONFIG_H261_DEMUXER)
    list(APPEND avformat_sources h261dec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_H263_DEMUXER)
    list(APPEND avformat_sources h263dec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_H264_DEMUXER)
    list(APPEND avformat_sources h264dec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_HCA_DEMUXER)
    list(APPEND avformat_sources hca.c)
endif()

if(CONFIG_HCOM_DEMUXER)
    list(APPEND avformat_sources hcom.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_HEVC_DEMUXER)
    list(APPEND avformat_sources hevcdec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_EVC_DEMUXER)
    list(APPEND avformat_sources evcdec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_HLS_DEMUXER)
    list(APPEND avformat_sources hls.c)
    list(APPEND avformat_sources hls_sample_encryption.c)
endif()

if(CONFIG_HNM_DEMUXER)
    list(APPEND avformat_sources hnm.c)
endif()

if(CONFIG_HXVS_DEMUXER)
    list(APPEND avformat_sources hxvs.c)
endif()

if(CONFIG_IAMF_DEMUXER)
    list(APPEND avformat_sources iamfdec.c)
endif()

if(CONFIG_ICO_DEMUXER)
    list(APPEND avformat_sources icodec.c)
endif()

if(CONFIG_IDCIN_DEMUXER)
    list(APPEND avformat_sources idcin.c)
endif()

if(CONFIG_IDF_DEMUXER)
    list(APPEND avformat_sources bintext.c)
    list(APPEND avformat_sources sauce.c)
endif()

if(CONFIG_IFF_DEMUXER)
    list(APPEND avformat_sources iff.c)
endif()

if(CONFIG_IFV_DEMUXER)
    list(APPEND avformat_sources ifv.c)
endif()

if(CONFIG_ILBC_DEMUXER)
    list(APPEND avformat_sources ilbc.c)
endif()

if(CONFIG_IMAGE2_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE2PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE2_ALIAS_PIX_DEMUXER)
    list(APPEND avformat_sources img2_alias_pix.c)
endif()

if(CONFIG_IMAGE2_BRENDER_PIX_DEMUXER)
    list(APPEND avformat_sources img2_brender_pix.c)
endif()

if(CONFIG_IMAGE_BMP_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_CRI_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_DDS_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_DPX_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_EXR_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_GEM_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_GIF_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_HDR_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_J2K_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_JPEG_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_JPEGLS_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_JPEGXL_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_JPEGXS_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PAM_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PBM_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PCX_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PFM_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PGMYUV_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PGM_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PGX_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PHM_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PHOTOCD_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PICTOR_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PNG_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PPM_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_PSD_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_QDRAW_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_QOI_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_SGI_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_SVG_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_SUNRAST_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_TIFF_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_VBN_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_WEBP_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_XBM_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_XPM_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMAGE_XWD_PIPE_DEMUXER)
    list(APPEND avformat_sources img2dec.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_IMF_DEMUXER)
    list(APPEND avformat_sources imfdec.c)
    list(APPEND avformat_sources imf_cpl.c)
endif()

if(CONFIG_INGENIENT_DEMUXER)
    list(APPEND avformat_sources ingenientdec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_IPMOVIE_DEMUXER)
    list(APPEND avformat_sources ipmovie.c)
endif()

if(CONFIG_IPU_DEMUXER)
    list(APPEND avformat_sources ipudec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_IRCAM_DEMUXER)
    list(APPEND avformat_sources ircamdec.c)
    list(APPEND avformat_sources ircam.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_ISS_DEMUXER)
    list(APPEND avformat_sources iss.c)
endif()

if(CONFIG_IV8_DEMUXER)
    list(APPEND avformat_sources iv8.c)
endif()

if(CONFIG_IVF_DEMUXER)
    list(APPEND avformat_sources ivfdec.c)
endif()

if(CONFIG_IVR_DEMUXER)
    list(APPEND avformat_sources rmdec.c)
    list(APPEND avformat_sources rm.c)
    list(APPEND avformat_sources rmsipr.c)
endif()

if(CONFIG_JACOSUB_DEMUXER)
    list(APPEND avformat_sources jacosubdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_JPEGXL_ANIM_DEMUXER)
    list(APPEND avformat_sources jpegxl_anim_dec.c)
endif()

if(CONFIG_JV_DEMUXER)
    list(APPEND avformat_sources jvdec.c)
endif()

if(CONFIG_KUX_DEMUXER)
    list(APPEND avformat_sources flvdec.c)
endif()

if(CONFIG_KVAG_DEMUXER)
    list(APPEND avformat_sources kvag.c)
endif()

if(CONFIG_LAF_DEMUXER)
    list(APPEND avformat_sources lafdec.c)
endif()

if(CONFIG_LC3_DEMUXER)
    list(APPEND avformat_sources lc3.c)
endif()

if(CONFIG_LMLM4_DEMUXER)
    list(APPEND avformat_sources lmlm4.c)
endif()

if(CONFIG_LOAS_DEMUXER)
    list(APPEND avformat_sources loasdec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_LUODAT_DEMUXER)
    list(APPEND avformat_sources luodatdec.c)
endif()

if(CONFIG_LRC_DEMUXER)
    list(APPEND avformat_sources lrcdec.c)
    list(APPEND avformat_sources lrc.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_LVF_DEMUXER)
    list(APPEND avformat_sources lvfdec.c)
endif()

if(CONFIG_LXF_DEMUXER)
    list(APPEND avformat_sources lxfdec.c)
endif()

if(CONFIG_M4V_DEMUXER)
    list(APPEND avformat_sources m4vdec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_MATROSKA_DEMUXER)
    list(APPEND avformat_sources matroskadec.c)
    list(APPEND avformat_sources matroska.c)
    list(APPEND avformat_sources flac_picture.c)
    list(APPEND avformat_sources rmsipr.c)
    list(APPEND avformat_sources oggparsevorbis.c)
    list(APPEND avformat_sources vorbiscomment.c)
    list(APPEND avformat_sources qtpalette.c)
    list(APPEND avformat_sources replaygain.c)
    list(APPEND avformat_sources dovi_isom.c)
endif()

if(CONFIG_MCA_DEMUXER)
    list(APPEND avformat_sources mca.c)
endif()

if(CONFIG_MCC_DEMUXER)
    list(APPEND avformat_sources mccdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_MGSTS_DEMUXER)
    list(APPEND avformat_sources mgsts.c)
endif()

if(CONFIG_MICRODVD_DEMUXER)
    list(APPEND avformat_sources microdvddec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_MJPEG_2000_DEMUXER)
    list(APPEND avformat_sources rawdec.c)
    list(APPEND avformat_sources mj2kdec.c)
endif()

if(CONFIG_MJPEG_DEMUXER)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_MLP_DEMUXER)
    list(APPEND avformat_sources rawdec.c)
    list(APPEND avformat_sources mlpdec.c)
endif()

if(CONFIG_MLV_DEMUXER)
    list(APPEND avformat_sources mlvdec.c)
    list(APPEND avformat_sources riffdec.c)
endif()

if(CONFIG_MM_DEMUXER)
    list(APPEND avformat_sources mm.c)
endif()

if(CONFIG_MMF_DEMUXER)
    list(APPEND avformat_sources mmf.c)
endif()

if(CONFIG_MODS_DEMUXER)
    list(APPEND avformat_sources mods.c)
endif()

if(CONFIG_MOFLEX_DEMUXER)
    list(APPEND avformat_sources moflex.c)
endif()

if(CONFIG_MOV_DEMUXER)
    list(APPEND avformat_sources mov.c)
    list(APPEND avformat_sources mov_chan.c)
    list(APPEND avformat_sources mov_esds.c)
    list(APPEND avformat_sources qtpalette.c)
    list(APPEND avformat_sources replaygain.c)
    list(APPEND avformat_sources dovi_isom.c)
    list(APPEND avformat_sources dvdclut.c)
endif()

if(CONFIG_MP3_DEMUXER)
    list(APPEND avformat_sources mp3dec.c)
    list(APPEND avformat_sources replaygain.c)
endif()

if(CONFIG_MPC_DEMUXER)
    list(APPEND avformat_sources mpc.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_MPC8_DEMUXER)
    list(APPEND avformat_sources mpc8.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_MPEGPS_DEMUXER)
    list(APPEND avformat_sources mpeg.c)
endif()

if(CONFIG_MPEGTS_DEMUXER)
    list(APPEND avformat_sources mpegts.c)
endif()

if(CONFIG_MPEGVIDEO_DEMUXER)
    list(APPEND avformat_sources mpegvideodec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_MPJPEG_DEMUXER)
    list(APPEND avformat_sources mpjpegdec.c)
endif()

if(CONFIG_MPL2_DEMUXER)
    list(APPEND avformat_sources mpl2dec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_MSF_DEMUXER)
    list(APPEND avformat_sources msf.c)
endif()

if(CONFIG_MPSUB_DEMUXER)
    list(APPEND avformat_sources mpsubdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_MSNWC_TCP_DEMUXER)
    list(APPEND avformat_sources msnwc_tcp.c)
endif()

if(CONFIG_MSP_DEMUXER)
    list(APPEND avformat_sources mspdec.c)
endif()

if(CONFIG_MTAF_DEMUXER)
    list(APPEND avformat_sources mtaf.c)
endif()

if(CONFIG_MTV_DEMUXER)
    list(APPEND avformat_sources mtv.c)
endif()

if(CONFIG_MUSX_DEMUXER)
    list(APPEND avformat_sources musx.c)
endif()

if(CONFIG_MV_DEMUXER)
    list(APPEND avformat_sources mvdec.c)
endif()

if(CONFIG_MVI_DEMUXER)
    list(APPEND avformat_sources mvi.c)
endif()

if(CONFIG_MXF_DEMUXER)
    list(APPEND avformat_sources mxfdec.c)
    list(APPEND avformat_sources mxf.c)
    list(APPEND avformat_sources avlanguage.c)
endif()

if(CONFIG_MXG_DEMUXER)
    list(APPEND avformat_sources mxg.c)
endif()

if(CONFIG_NC_DEMUXER)
    list(APPEND avformat_sources ncdec.c)
endif()

if(CONFIG_NISTSPHERE_DEMUXER)
    list(APPEND avformat_sources nistspheredec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_NSP_DEMUXER)
    list(APPEND avformat_sources nspdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_NSV_DEMUXER)
    list(APPEND avformat_sources nsvdec.c)
endif()

if(CONFIG_NUT_DEMUXER)
    list(APPEND avformat_sources nutdec.c)
    list(APPEND avformat_sources nut.c)
endif()

if(CONFIG_NUV_DEMUXER)
    list(APPEND avformat_sources nuv.c)
endif()

if(CONFIG_AV1_DEMUXER)
    list(APPEND avformat_sources av1dec.c)
endif()

if(CONFIG_OBU_DEMUXER)
    list(APPEND avformat_sources av1dec.c)
endif()

if(CONFIG_OGG_DEMUXER)
    list(APPEND avformat_sources oggdec.c)
    list(APPEND avformat_sources oggparsecelt.c)
    list(APPEND avformat_sources oggparsedirac.c)
    list(APPEND avformat_sources oggparseflac.c)
    list(APPEND avformat_sources oggparseogm.c)
    list(APPEND avformat_sources oggparseopus.c)
    list(APPEND avformat_sources oggparseskeleton.c)
    list(APPEND avformat_sources oggparsespeex.c)
    list(APPEND avformat_sources oggparsetheora.c)
    list(APPEND avformat_sources oggparsevorbis.c)
    list(APPEND avformat_sources oggparsevp8.c)
    list(APPEND avformat_sources replaygain.c)
    list(APPEND avformat_sources vorbiscomment.c)
    list(APPEND avformat_sources flac_picture.c)
endif()

if(CONFIG_OMA_DEMUXER)
    list(APPEND avformat_sources omadec.c)
    list(APPEND avformat_sources pcm.c)
    list(APPEND avformat_sources oma.c)
endif()

if(CONFIG_OSQ_DEMUXER)
    list(APPEND avformat_sources osq.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_PAF_DEMUXER)
    list(APPEND avformat_sources paf.c)
endif()

if(CONFIG_PCM_ALAW_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_F32BE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_F32LE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_F64BE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_F64LE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_MULAW_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_S16BE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_S16LE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_S24BE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_S24LE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_S32BE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_S32LE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_S8_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_U16BE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_U16LE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_U24BE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_U24LE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_U32BE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_U32LE_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_U8_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PCM_VIDC_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_PDV_DEMUXER)
    list(APPEND avformat_sources pdvdec.c)
endif()

if(CONFIG_PJS_DEMUXER)
    list(APPEND avformat_sources pjsdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_PMP_DEMUXER)
    list(APPEND avformat_sources pmpdec.c)
endif()

if(CONFIG_PP_BNK_DEMUXER)
    list(APPEND avformat_sources pp_bnk.c)
endif()

if(CONFIG_PVA_DEMUXER)
    list(APPEND avformat_sources pva.c)
endif()

if(CONFIG_PVF_DEMUXER)
    list(APPEND avformat_sources pvfdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_QCP_DEMUXER)
    list(APPEND avformat_sources qcp.c)
endif()

if(CONFIG_QOA_DEMUXER)
    list(APPEND avformat_sources qoadec.c)
endif()

if(CONFIG_R3D_DEMUXER)
    list(APPEND avformat_sources r3d.c)
endif()

if(CONFIG_RAWVIDEO_DEMUXER)
    list(APPEND avformat_sources rawvideodec.c)
endif()

if(CONFIG_RCWT_DEMUXER)
    list(APPEND avformat_sources rcwtdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_REALTEXT_DEMUXER)
    list(APPEND avformat_sources realtextdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_REDSPARK_DEMUXER)
    list(APPEND avformat_sources redspark.c)
endif()

if(CONFIG_RKA_DEMUXER)
    list(APPEND avformat_sources rka.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_RL2_DEMUXER)
    list(APPEND avformat_sources rl2.c)
endif()

if(CONFIG_RM_DEMUXER)
    list(APPEND avformat_sources rmdec.c)
    list(APPEND avformat_sources rm.c)
    list(APPEND avformat_sources rmsipr.c)
endif()

if(CONFIG_ROQ_DEMUXER)
    list(APPEND avformat_sources idroqdec.c)
endif()

if(CONFIG_RSD_DEMUXER)
    list(APPEND avformat_sources rsd.c)
endif()

if(CONFIG_RPL_DEMUXER)
    list(APPEND avformat_sources rpl.c)
endif()

if(CONFIG_RSO_DEMUXER)
    list(APPEND avformat_sources rsodec.c)
    list(APPEND avformat_sources rso.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_RTSP_DEMUXER)
    list(APPEND avformat_sources rtsp.c)
    list(APPEND avformat_sources rtspdec.c)
    list(APPEND avformat_sources httpauth.c)
endif()

if(CONFIG_S337M_DEMUXER)
    list(APPEND avformat_sources s337m.c)
    list(APPEND avformat_sources spdif.c)
endif()

if(CONFIG_SAMI_DEMUXER)
    list(APPEND avformat_sources samidec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_SAP_DEMUXER)
    list(APPEND avformat_sources sapdec.c)
endif()

if(CONFIG_SBC_DEMUXER)
    list(APPEND avformat_sources sbcdec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_SBG_DEMUXER)
    list(APPEND avformat_sources sbgdec.c)
endif()

if(CONFIG_SCC_DEMUXER)
    list(APPEND avformat_sources sccdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_SCD_DEMUXER)
    list(APPEND avformat_sources scd.c)
endif()

if(CONFIG_SDNS_DEMUXER)
    list(APPEND avformat_sources sdns.c)
endif()

if(CONFIG_SDP_DEMUXER)
    list(APPEND avformat_sources rtsp.c)
endif()

if(CONFIG_SDR2_DEMUXER)
    list(APPEND avformat_sources sdr2.c)
endif()

if(CONFIG_SDS_DEMUXER)
    list(APPEND avformat_sources sdsdec.c)
endif()

if(CONFIG_SDX_DEMUXER)
    list(APPEND avformat_sources sdxdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_SEGAFILM_DEMUXER)
    list(APPEND avformat_sources segafilm.c)
endif()

if(CONFIG_SER_DEMUXER)
    list(APPEND avformat_sources serdec.c)
endif()

if(CONFIG_SGA_DEMUXER)
    list(APPEND avformat_sources sga.c)
endif()

if(CONFIG_SHORTEN_DEMUXER)
    list(APPEND avformat_sources shortendec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_SIFF_DEMUXER)
    list(APPEND avformat_sources siff.c)
endif()

if(CONFIG_SIMBIOSIS_IMX_DEMUXER)
    list(APPEND avformat_sources imx.c)
endif()

if(CONFIG_SLN_DEMUXER)
    list(APPEND avformat_sources pcmdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_SMACKER_DEMUXER)
    list(APPEND avformat_sources smacker.c)
endif()

if(CONFIG_SMJPEG_DEMUXER)
    list(APPEND avformat_sources smjpegdec.c)
    list(APPEND avformat_sources smjpeg.c)
endif()

if(CONFIG_SMUSH_DEMUXER)
    list(APPEND avformat_sources smush.c)
endif()

if(CONFIG_SOL_DEMUXER)
    list(APPEND avformat_sources sol.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_SOX_DEMUXER)
    list(APPEND avformat_sources soxdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_SPDIF_DEMUXER)
    list(APPEND avformat_sources spdif.c)
    list(APPEND avformat_sources spdifdec.c)
endif()

if(CONFIG_SRT_DEMUXER)
    list(APPEND avformat_sources srtdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_STL_DEMUXER)
    list(APPEND avformat_sources stldec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_STR_DEMUXER)
    list(APPEND avformat_sources psxstr.c)
endif()

if(CONFIG_SUBVIEWER1_DEMUXER)
    list(APPEND avformat_sources subviewer1dec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_SUBVIEWER_DEMUXER)
    list(APPEND avformat_sources subviewerdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_SUP_DEMUXER)
    list(APPEND avformat_sources supdec.c)
endif()

if(CONFIG_SVAG_DEMUXER)
    list(APPEND avformat_sources svag.c)
endif()

if(CONFIG_SVS_DEMUXER)
    list(APPEND avformat_sources svs.c)
endif()

if(CONFIG_SWF_DEMUXER)
    list(APPEND avformat_sources swfdec.c)
    list(APPEND avformat_sources swf.c)
endif()

if(CONFIG_TAK_DEMUXER)
    list(APPEND avformat_sources takdec.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_TEDCAPTIONS_DEMUXER)
    list(APPEND avformat_sources tedcaptionsdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_THP_DEMUXER)
    list(APPEND avformat_sources thp.c)
endif()

if(CONFIG_THREEDOSTR_DEMUXER)
    list(APPEND avformat_sources 3dostr.c)
endif()

if(CONFIG_TIERTEXSEQ_DEMUXER)
    list(APPEND avformat_sources tiertexseq.c)
endif()

if(CONFIG_TMV_DEMUXER)
    list(APPEND avformat_sources tmv.c)
endif()

if(CONFIG_TRUEHD_DEMUXER)
    list(APPEND avformat_sources rawdec.c)
    list(APPEND avformat_sources mlpdec.c)
endif()

if(CONFIG_TTA_DEMUXER)
    list(APPEND avformat_sources tta.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_TTY_DEMUXER)
    list(APPEND avformat_sources tty.c)
    list(APPEND avformat_sources sauce.c)
endif()

if(CONFIG_TY_DEMUXER)
    list(APPEND avformat_sources ty.c)
endif()

if(CONFIG_TXD_DEMUXER)
    list(APPEND avformat_sources txd.c)
endif()

if(CONFIG_USM_DEMUXER)
    list(APPEND avformat_sources usmdec.c)
endif()

if(CONFIG_V210_DEMUXER)
    list(APPEND avformat_sources rawvideodec.c)
endif()

if(CONFIG_V210X_DEMUXER)
    list(APPEND avformat_sources rawvideodec.c)
endif()

if(CONFIG_VAG_DEMUXER)
    list(APPEND avformat_sources vag.c)
endif()

if(CONFIG_VC1_DEMUXER)
    list(APPEND avformat_sources rawdec.c)
    list(APPEND avformat_sources vc1dec.c)
endif()

if(CONFIG_VC1T_DEMUXER)
    list(APPEND avformat_sources vc1test.c)
endif()

if(CONFIG_VIVIDAS_DEMUXER)
    list(APPEND avformat_sources vividas.c)
endif()

if(CONFIG_VIVO_DEMUXER)
    list(APPEND avformat_sources vivo.c)
endif()

if(CONFIG_VMD_DEMUXER)
    list(APPEND avformat_sources sierravmd.c)
endif()

if(CONFIG_VOBSUB_DEMUXER)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_VOC_DEMUXER)
    list(APPEND avformat_sources vocdec.c)
    list(APPEND avformat_sources voc_packet.c)
    list(APPEND avformat_sources voc.c)
endif()

if(CONFIG_VPK_DEMUXER)
    list(APPEND avformat_sources vpk.c)
endif()

if(CONFIG_VPLAYER_DEMUXER)
    list(APPEND avformat_sources vplayerdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_VQF_DEMUXER)
    list(APPEND avformat_sources vqf.c)
endif()

if(CONFIG_VVC_DEMUXER)
    list(APPEND avformat_sources vvcdec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_W64_DEMUXER)
    list(APPEND avformat_sources wavdec.c)
    list(APPEND avformat_sources w64.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_WADY_DEMUXER)
    list(APPEND avformat_sources wady.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_WAVARC_DEMUXER)
    list(APPEND avformat_sources wavarc.c)
endif()

if(CONFIG_WAV_DEMUXER)
    list(APPEND avformat_sources wavdec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_WC3_DEMUXER)
    list(APPEND avformat_sources wc3movie.c)
endif()

if(CONFIG_WEBVTT_DEMUXER)
    list(APPEND avformat_sources webvttdec.c)
    list(APPEND avformat_sources subtitles.c)
endif()

if(CONFIG_WSAUD_DEMUXER)
    list(APPEND avformat_sources westwood_aud.c)
endif()

if(CONFIG_WSD_DEMUXER)
    list(APPEND avformat_sources wsddec.c)
    list(APPEND avformat_sources rawdec.c)
endif()

if(CONFIG_WSVQA_DEMUXER)
    list(APPEND avformat_sources westwood_vqa.c)
endif()

if(CONFIG_WTV_DEMUXER)
    list(APPEND avformat_sources wtvdec.c)
    list(APPEND avformat_sources wtv_common.c)
    list(APPEND avformat_sources asf.c)
endif()

if(CONFIG_WV_DEMUXER)
    list(APPEND avformat_sources wvdec.c)
    list(APPEND avformat_sources wv.c)
    list(APPEND avformat_sources apetag.c)
    list(APPEND avformat_sources img2.c)
endif()

if(CONFIG_WVE_DEMUXER)
    list(APPEND avformat_sources wvedec.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_XA_DEMUXER)
    list(APPEND avformat_sources xa.c)
endif()

if(CONFIG_XBIN_DEMUXER)
    list(APPEND avformat_sources bintext.c)
    list(APPEND avformat_sources sauce.c)
endif()

if(CONFIG_XMD_DEMUXER)
    list(APPEND avformat_sources xmd.c)
    list(APPEND avformat_sources pcm.c)
endif()

if(CONFIG_XMV_DEMUXER)
    list(APPEND avformat_sources xmv.c)
endif()

if(CONFIG_XVAG_DEMUXER)
    list(APPEND avformat_sources xvag.c)
endif()

if(CONFIG_XWMA_DEMUXER)
    list(APPEND avformat_sources xwma.c)
endif()

if(CONFIG_YOP_DEMUXER)
    list(APPEND avformat_sources yop.c)
endif()

if(CONFIG_YUV4MPEGPIPE_DEMUXER)
    list(APPEND avformat_sources yuv4mpegdec.c)
endif()

if(CONFIG_AVISYNTH_DEMUXER)
    list(APPEND avformat_sources avisynth.c)
endif()

if(CONFIG_LIBGME_DEMUXER)
    list(APPEND avformat_sources libgme.c)
endif()

if(CONFIG_LIBMODPLUG_DEMUXER)
    list(APPEND avformat_sources libmodplug.c)
endif()

if(CONFIG_LIBOPENMPT_DEMUXER)
    list(APPEND avformat_sources libopenmpt.c)
endif()

if(CONFIG_VAPOURSYNTH_DEMUXER)
    list(APPEND avformat_sources vapoursynth.c)
endif()

# --- Protocols ---
if(CONFIG_ANDROID_CONTENT_PROTOCOL)
    list(APPEND avformat_sources file.c)
endif()

if(CONFIG_ASYNC_PROTOCOL)
    list(APPEND avformat_sources async.c)
endif()

if(CONFIG_BLURAY_PROTOCOL)
    list(APPEND avformat_sources bluray.c)
endif()

if(CONFIG_CACHE_PROTOCOL)
    list(APPEND avformat_sources cache.c)
endif()

if(CONFIG_CONCAT_PROTOCOL)
    list(APPEND avformat_sources concat.c)
endif()

if(CONFIG_CONCATF_PROTOCOL)
    list(APPEND avformat_sources concat.c)
endif()

if(CONFIG_CRYPTO_PROTOCOL)
    list(APPEND avformat_sources crypto.c)
endif()

if(CONFIG_DATA_PROTOCOL)
    list(APPEND avformat_sources data_uri.c)
endif()

if(CONFIG_FFRTMPCRYPT_PROTOCOL)
    list(APPEND avformat_sources rtmpcrypt.c)
    list(APPEND avformat_sources rtmpdigest.c)
    list(APPEND avformat_sources rtmpdh.c)
endif()

if(CONFIG_FFRTMPHTTP_PROTOCOL)
    list(APPEND avformat_sources rtmphttp.c)
endif()

if(CONFIG_FILE_PROTOCOL)
    list(APPEND avformat_sources file.c)
endif()

if(CONFIG_FD_PROTOCOL)
    list(APPEND avformat_sources file.c)
endif()

if(CONFIG_FTP_PROTOCOL)
    list(APPEND avformat_sources ftp.c)
endif()

if(CONFIG_GOPHER_PROTOCOL)
    list(APPEND avformat_sources gopher.c)
endif()

if(CONFIG_GOPHERS_PROTOCOL)
    list(APPEND avformat_sources gopher.c)
endif()

if(CONFIG_HTTP_PROTOCOL)
    list(APPEND avformat_sources http.c)
    list(APPEND avformat_sources httpauth.c)
endif()

if(CONFIG_HTTPPROXY_PROTOCOL)
    list(APPEND avformat_sources http.c)
    list(APPEND avformat_sources httpauth.c)
endif()

if(CONFIG_HTTPS_PROTOCOL)
    list(APPEND avformat_sources http.c)
    list(APPEND avformat_sources httpauth.c)
endif()

if(CONFIG_ICECAST_PROTOCOL)
    list(APPEND avformat_sources icecast.c)
endif()

if(CONFIG_MD5_PROTOCOL)
    list(APPEND avformat_sources md5proto.c)
endif()

if(CONFIG_MMSH_PROTOCOL)
    list(APPEND avformat_sources mmsh.c)
    list(APPEND avformat_sources mms.c)
    list(APPEND avformat_sources asf_tags.c)
endif()

if(CONFIG_MMST_PROTOCOL)
    list(APPEND avformat_sources mmst.c)
    list(APPEND avformat_sources mms.c)
    list(APPEND avformat_sources asf_tags.c)
endif()

if(CONFIG_PIPE_PROTOCOL)
    list(APPEND avformat_sources file.c)
endif()

if(CONFIG_PROMPEG_PROTOCOL)
    list(APPEND avformat_sources prompeg.c)
endif()

if(CONFIG_RTMP_PROTOCOL)
    list(APPEND avformat_sources rtmpproto.c)
    list(APPEND avformat_sources rtmpdigest.c)
    list(APPEND avformat_sources rtmppkt.c)
endif()

if(CONFIG_RTMPE_PROTOCOL)
    list(APPEND avformat_sources rtmpproto.c)
    list(APPEND avformat_sources rtmpdigest.c)
    list(APPEND avformat_sources rtmppkt.c)
endif()

if(CONFIG_RTMPS_PROTOCOL)
    list(APPEND avformat_sources rtmpproto.c)
    list(APPEND avformat_sources rtmpdigest.c)
    list(APPEND avformat_sources rtmppkt.c)
endif()

if(CONFIG_RTMPT_PROTOCOL)
    list(APPEND avformat_sources rtmpproto.c)
    list(APPEND avformat_sources rtmpdigest.c)
    list(APPEND avformat_sources rtmppkt.c)
endif()

if(CONFIG_RTMPTE_PROTOCOL)
    list(APPEND avformat_sources rtmpproto.c)
    list(APPEND avformat_sources rtmpdigest.c)
    list(APPEND avformat_sources rtmppkt.c)
endif()

if(CONFIG_RTMPTS_PROTOCOL)
    list(APPEND avformat_sources rtmpproto.c)
    list(APPEND avformat_sources rtmpdigest.c)
    list(APPEND avformat_sources rtmppkt.c)
endif()

if(CONFIG_RTP_PROTOCOL)
    list(APPEND avformat_sources rtpproto.c)
    list(APPEND avformat_sources ip.c)
endif()

if(CONFIG_SCTP_PROTOCOL)
    list(APPEND avformat_sources sctp.c)
endif()

if(CONFIG_SRTP_PROTOCOL)
    list(APPEND avformat_sources srtpproto.c)
    list(APPEND avformat_sources srtp.c)
endif()

if(CONFIG_SUBFILE_PROTOCOL)
    list(APPEND avformat_sources subfile.c)
endif()

if(CONFIG_TEE_PROTOCOL)
    list(APPEND avformat_sources teeproto.c)
    list(APPEND avformat_sources tee_common.c)
endif()

if(CONFIG_TCP_PROTOCOL)
    list(APPEND avformat_sources tcp.c)
endif()

if(CONFIG_IPFS_GATEWAY_PROTOCOL)
    list(APPEND avformat_sources ipfsgateway.c)
endif()

if(CONFIG_IPNS_GATEWAY_PROTOCOL)
    list(APPEND avformat_sources ipfsgateway.c)
endif()

if(CONFIG_TLS_PROTOCOL)
    list(APPEND avformat_sources tls.c)
endif()

if(CONFIG_DTLS_PROTOCOL)
    list(APPEND avformat_sources tls.c)
endif()

# TLS backend implementations (from TLS-OBJS-$(CONFIG_*) in Makefile)
# These are included when either TLS_PROTOCOL or DTLS_PROTOCOL is enabled
if(CONFIG_TLS_PROTOCOL OR CONFIG_DTLS_PROTOCOL)
    if(CONFIG_GNUTLS)
        list(APPEND avformat_sources tls_gnutls.c)
    endif()
    if(CONFIG_LIBTLS)
        list(APPEND avformat_sources tls_libtls.c)
    endif()
    if(CONFIG_MBEDTLS)
        list(APPEND avformat_sources tls_mbedtls.c)
    endif()
    if(CONFIG_OPENSSL)
        list(APPEND avformat_sources tls_openssl.c)
    endif()
    if(CONFIG_SECURETRANSPORT)
        list(APPEND avformat_sources tls_securetransport.c)
    endif()
    if(CONFIG_SCHANNEL)
        list(APPEND avformat_sources tls_schannel.c)
    endif()
endif()

if(CONFIG_UDP_PROTOCOL)
    list(APPEND avformat_sources udp.c)
    list(APPEND avformat_sources ip.c)
endif()

if(CONFIG_UDPLITE_PROTOCOL)
    list(APPEND avformat_sources udp.c)
    list(APPEND avformat_sources ip.c)
endif()

if(CONFIG_UNIX_PROTOCOL)
    list(APPEND avformat_sources unix.c)
endif()

if(CONFIG_LIBAMQP_PROTOCOL)
    list(APPEND avformat_sources libamqp.c)
endif()

if(CONFIG_LIBRIST_PROTOCOL)
    list(APPEND avformat_sources librist.c)
endif()

if(CONFIG_LIBRTMP_PROTOCOL)
    list(APPEND avformat_sources librtmp.c)
endif()

if(CONFIG_LIBRTMPE_PROTOCOL)
    list(APPEND avformat_sources librtmp.c)
endif()

if(CONFIG_LIBRTMPS_PROTOCOL)
    list(APPEND avformat_sources librtmp.c)
endif()

if(CONFIG_LIBRTMPT_PROTOCOL)
    list(APPEND avformat_sources librtmp.c)
endif()

if(CONFIG_LIBRTMPTE_PROTOCOL)
    list(APPEND avformat_sources librtmp.c)
endif()

if(CONFIG_LIBSMBCLIENT_PROTOCOL)
    list(APPEND avformat_sources libsmbclient.c)
endif()

if(CONFIG_LIBSRT_PROTOCOL)
    list(APPEND avformat_sources libsrt.c)
endif()

if(CONFIG_LIBSSH_PROTOCOL)
    list(APPEND avformat_sources libssh.c)
endif()

if(CONFIG_LIBZMQ_PROTOCOL)
    list(APPEND avformat_sources libzmq.c)
endif()

# ============================================================================
# Remove duplicates
# ============================================================================
list(REMOVE_DUPLICATES avformat_sources)

# Filter out source files that don't exist
set(avformat_sources_filtered "")
foreach(src IN LISTS avformat_sources)
    if(IS_ABSOLUTE "${src}")
        list(APPEND avformat_sources_filtered "${src}")
    elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
        list(APPEND avformat_sources_filtered "${src}")
    else()
        message(STATUS "avformat: skipping missing source file: ${src}")
    endif()
endforeach()
set(avformat_sources ${avformat_sources_filtered})

# ============================================================================
# Generate muxer_list.c, demuxer_list.c, protocol_list.c
# by scanning the actual source files that will be compiled
# ============================================================================
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/libavformat")

set(_muxer_syms "")
set(_demuxer_syms "")
set(_protocol_syms "")

foreach(_src IN LISTS avformat_sources)
    if(IS_ABSOLUTE "${_src}")
        set(_src_abs "${_src}")
    else()
        set(_src_abs "${CMAKE_CURRENT_SOURCE_DIR}/${_src}")
    endif()
    if(NOT EXISTS "${_src_abs}")
        continue()
    endif()
    get_filename_component(_src_name "${_src_abs}" NAME)
    # Skip allformats.c and protocols.c - they only have extern declarations
    if("${_src_name}" STREQUAL "allformats.c" OR "${_src_name}" STREQUAL "protocols.c")
        continue()
    endif()
    file(STRINGS "${_src_abs}" _lines
        REGEX "^(const[ \t]+FFOutputFormat|const[ \t]+FFInputFormat|const[ \t]+URLProtocol)[ \t]+ff_[a-zA-Z0-9_]+")
    foreach(_line IN LISTS _lines)
        if(_line MATCHES "const[ \t]+FFOutputFormat[ \t]+(ff_[a-zA-Z0-9_]+_muxer)")
            list(APPEND _muxer_syms "${CMAKE_MATCH_1}")
        elseif(_line MATCHES "const[ \t]+FFInputFormat[ \t]+(ff_[a-zA-Z0-9_]+_demuxer)")
            list(APPEND _demuxer_syms "${CMAKE_MATCH_1}")
        elseif(_line MATCHES "const[ \t]+URLProtocol[ \t]+(ff_[a-zA-Z0-9_]+_protocol)")
            list(APPEND _protocol_syms "${CMAKE_MATCH_1}")
        endif()
    endforeach()
endforeach()

list(REMOVE_DUPLICATES _muxer_syms)
list(REMOVE_DUPLICATES _demuxer_syms)
list(REMOVE_DUPLICATES _protocol_syms)
list(SORT _muxer_syms)
list(SORT _demuxer_syms)
list(SORT _protocol_syms)

# Remove symbols that are conditionally compiled and not available on this platform
list(REMOVE_ITEM _muxer_syms ff_fifo_test_muxer)
list(REMOVE_ITEM _protocol_syms ff_android_content_protocol ff_async_test_protocol)

if(NOT CONFIG_TLS_PROTOCOL AND NOT CONFIG_DTLS_PROTOCOL)
    list(REMOVE_ITEM _protocol_syms ff_gophers_protocol ff_https_protocol ff_tls_protocol)
endif()
if(NOT CONFIG_DTLS_PROTOCOL)
    list(REMOVE_ITEM _protocol_syms ff_dtls_protocol)
endif()
if(NOT CONFIG_WHIP_MUXER)
    list(REMOVE_ITEM _muxer_syms ff_whip_muxer)
endif()

# Write muxer_list.c
set(_content "/* Auto-generated by CMake - do not edit! */\n#include \"libavformat/internal.h\"\n\n")
foreach(_sym IN LISTS _muxer_syms)
    string(APPEND _content "extern const FFOutputFormat ${_sym};\n")
endforeach()
string(APPEND _content "\nstatic const FFOutputFormat * const muxer_list[] = {\n")
foreach(_sym IN LISTS _muxer_syms)
    string(APPEND _content "    &${_sym},\n")
endforeach()
string(APPEND _content "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/muxer_list.c" "${_content}")

# Write demuxer_list.c
set(_content "/* Auto-generated by CMake - do not edit! */\n#include \"libavformat/internal.h\"\n\n")
foreach(_sym IN LISTS _demuxer_syms)
    string(APPEND _content "extern const FFInputFormat ${_sym};\n")
endforeach()
string(APPEND _content "\nstatic const FFInputFormat * const demuxer_list[] = {\n")
foreach(_sym IN LISTS _demuxer_syms)
    string(APPEND _content "    &${_sym},\n")
endforeach()
string(APPEND _content "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/demuxer_list.c" "${_content}")

# Write protocol_list.c
set(_content "/* Auto-generated by CMake - do not edit! */\n#include \"libavformat/url.h\"\n\n")
foreach(_sym IN LISTS _protocol_syms)
    string(APPEND _content "extern const URLProtocol ${_sym};\n")
endforeach()
string(APPEND _content "\nstatic const URLProtocol * const url_protocols[] = {\n")
foreach(_sym IN LISTS _protocol_syms)
    string(APPEND _content "    &${_sym},\n")
endforeach()
string(APPEND _content "    NULL\n};\n")
file(WRITE "${CMAKE_BINARY_DIR}/libavformat/protocol_list.c" "${_content}")

list(LENGTH _muxer_syms _nmux)
list(LENGTH _demuxer_syms _ndemux)
list(LENGTH _protocol_syms _nproto)
message(STATUS "libavformat: ${_nmux} muxers, ${_ndemux} demuxers, ${_nproto} protocols")

# ============================================================================
# Create the library
# ============================================================================
add_library(avformat STATIC ${avformat_sources})

# Include directories
target_include_directories(avformat
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

# Link dependencies
target_link_libraries(avformat
    PRIVATE
        avcodec
        avutil
        Threads::Threads
)

# Link OpenSSL if enabled (needed for RTMP DH, TLS)
if(CONFIG_OPENSSL AND OPENSSL_FOUND)
    target_link_libraries(avformat PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()

# Link GnuTLS if enabled (needed for tls_gnutls.c)
if(CONFIG_GNUTLS AND GNUTLS_FOUND)
    if(TARGET PkgConfig::GNUTLS)
        target_link_libraries(avformat PRIVATE PkgConfig::GNUTLS)
    else()
        target_link_libraries(avformat PRIVATE ${GNUTLS_LIBRARIES})
        target_include_directories(avformat PRIVATE ${GNUTLS_INCLUDE_DIRS})
        if(GNUTLS_LIBRARY_DIRS)
            target_link_directories(avformat PRIVATE ${GNUTLS_LIBRARY_DIRS})
        endif()
    endif()
endif()

# Link libxml2 if available (needed for dashdec.c DASH demuxer)
if(CONFIG_LIBXML2 AND libxml2_found)
    if(PC_LIBXML2_LDFLAGS)
        target_link_libraries(avformat PRIVATE ${PC_LIBXML2_LDFLAGS})
    endif()
    if(PC_LIBXML2_INCLUDE_DIRS)
        target_include_directories(avformat PRIVATE ${PC_LIBXML2_INCLUDE_DIRS})
    endif()
    message(STATUS "avformat: linking libxml2")
else()
    message(STATUS "avformat: libxml2 not found, excluding dashdec.c, imfdec.c, imf_cpl.c")
    get_target_property(_avfmt_srcs avformat SOURCES)
    list(FILTER _avfmt_srcs EXCLUDE REGEX "(dashdec|imfdec|imf_cpl)\.c$")
    set_target_properties(avformat PROPERTIES SOURCES "${_avfmt_srcs}")

    set(_stub_file "${CMAKE_CURRENT_BINARY_DIR}/avformat_xml_stubs.c")
    file(WRITE "${_stub_file}" "
/* Auto-generated stub: provides empty demuxer/muxer/protocol structs when deps are absent */
#include \"avformat.h\"
#include \"demux.h\"
#include \"mux.h\"
#include \"url.h\"

/* Stub for DASH demuxer (requires libxml2) */
const FFInputFormat ff_dash_demuxer = {
    .p.name = \"dash\",
    .p.long_name = \"Dynamic Adaptive Streaming over HTTP (stub)\",
};

/* Stub for IMF demuxer (requires libxml2) */
const FFInputFormat ff_imf_demuxer = {
    .p.name = \"imf\",
    .p.long_name = \"IMF (Interoperable Master Format) (stub)\",
};

/* Stub for WHIP muxer (requires OpenSSL) */
const FFOutputFormat ff_whip_muxer = {
    .p.name = \"whip\",
    .p.long_name = \"WebRTC WHIP (stub)\",
};

/* Stub for Unix domain socket protocol (requires sys/un.h, POSIX only) */
const URLProtocol ff_unix_protocol = {
    .name = \"unix\",
};
")
    target_sources(avformat PRIVATE "${_stub_file}")
endif()

# Link zlib if available (needed for mov.c, http.c, etc.)
find_package(ZLIB QUIET)
if(ZLIB_FOUND)
    target_link_libraries(avformat PRIVATE ZLIB::ZLIB)
endif()

# On Windows, exclude files that require POSIX-only headers
if(WIN32)
    get_target_property(_avfmt_srcs avformat SOURCES)
    list(FILTER _avfmt_srcs EXCLUDE REGEX "unix\.c$")
    if(NOT OPENSSL_FOUND AND LIBXML2_FOUND)
        list(FILTER _avfmt_srcs EXCLUDE REGEX "whip\.c$")
    elseif(NOT OPENSSL_FOUND AND NOT LIBXML2_FOUND)
        list(FILTER _avfmt_srcs EXCLUDE REGEX "whip\.c$")
    endif()
    set_target_properties(avformat PROPERTIES SOURCES "${_avfmt_srcs}")
    target_link_libraries(avformat PRIVATE ws2_32)
endif()

# External library include/link are handled centrally in cmake/FFmpegApplyExternalLibs.cmake

# Compiler definitions
target_compile_definitions(avformat PRIVATE
    HAVE_AV_CONFIG_H
    BUILDING_avformat
)

# Position independent code for shared builds
set_pic_if_needed(avformat)

# Set output name
set_target_properties(avformat PROPERTIES
    OUTPUT_NAME avformat
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

message(STATUS "libavformat configured")
