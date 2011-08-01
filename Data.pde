int a_second = 1000;
int a_minute = 60 * a_second;

String[] frame_times = new String[] {
  "1 second"
, "5 seconds"
, "10 seconds"
, "15 seconds"
, "20 seconds"
, "30 seconds"
, "45 seconds"
, "one minute"
, "two minutes"
, "five minutes"
};

int[] frame_times_milis = new int[] {
   1 * a_second
,  5 * a_second
, 10 * a_second
, 15 * a_second
, 20 * a_second
, 30 * a_second
, 45 * a_second
,  1 * a_minute
,  2 * a_minute
,  5 * a_minute
};

String[] resolutions = new String[] {
  " 320 x  240 - QVGA"
, " 640 x  480 - VGA"
, " 768 x  576 - PAL"
, " 800 x  600 - SVGA"
, "1280 x  720 - HD 720"
, "1280 x  768 - WXGA"
, "1280 x  800 - WXGA"
, "1600 x 1200 - UXGA"
, "1920 x 1080 - HD 1080"
, "1920 x 1200 - WUXGA"
};

int[] res_widths = new int[] {
  320
, 640
, 768
, 800
, 1280
, 1280
, 1280
, 1600
, 1920
, 1920
};

int[] res_heights = new int[] {
  240
, 480
, 576
, 600
, 720
, 768
, 800
, 1200
, 1080
, 1200
};
