requiredVHDLTopConstraints = Constraints {
  rawConstraints = [
      "CONFIG VCCAUX = \"3.3\"",
      "TIMESPEC \"TS_clk_in\" = PERIOD \"clk_in\" 20000 ps INPUT_JITTER 200 ps"
      ],
  netConstraints = [
      ("clk_in", [("LOC","\"H17\""), ("IOSTANDARD", "LVTTL")]),
      ("clk_in", [("TNM_NET", "\"clk_in\"")])
      ]
  }

requiredClashTopConstraints = Constraints {
  rawConstraints = [
      "CONFIG VCCAUX = \"3.3\"",
      "TIMESPEC \"TS_clk_in\" = PERIOD \"clk_in(0)\" 20000 ps INPUT_JITTER 200 ps"
      ],
  netConstraints = [
      ("clk_in(0)", [("LOC","\"H17\""), ("IOSTANDARD", "LVTTL")]),
      ("clk_in(0)", [("TNM_NET", "\"clk_in(0)\"")])
      ]
  }


switchNet = Constraints {
 rawConstraints = [
     "NET \"switch\" LOC = \"N14\" | IOSTANDARD = LVTTL | PULLDOWN"
     ],
 netConstraints = []
 }

tmdsNets = Constraints {
  rawConstraints = [],
  netConstraints = [
      ("tmds_p(0)", [ ("LOC", "\"T6\""), ("IOSTANDARD", "TMDS_33") ]),
      ("tmds_p(1)", [ ("LOC", "\"U7\""), ("IOSTANDARD", "TMDS_33") ]),
      ("tmds_p(2)", [ ("LOC", "\"U8\""), ("IOSTANDARD", "TMDS_33") ]),
      ("tmds_p(3)", [ ("LOC", "\"U5\""), ("IOSTANDARD", "TMDS_33") ]),
      ("tmds_n(0)", [ ("LOC", "\"V6\""), ("IOSTANDARD", "TMDS_33") ]),
      ("tmds_n(1)", [ ("LOC", "\"V7\""), ("IOSTANDARD", "TMDS_33") ]),
      ("tmds_n(2)", [ ("LOC", "\"V8\""), ("IOSTANDARD", "TMDS_33") ]),
      ("tmds_n(3)", [ ("LOC", "\"V5\""), ("IOSTANDARD", "TMDS_33") ])
      ]
  }

audioNets = Constraints {
  rawConstraints = [],
  netConstraints = [
      ("audio(0)", [("LOC", "\"R7\""), ("IOSTANDARD", "LVTTL"),
                    ("SLEW", "SLOW"),  ("DRIVE", "8")]),
      ("audio(1)", [("LOC", "\"T7\""), ("IOSTANDARD", "LVTTL"),
                    ("SLEW", "SLOW"),  ("DRIVE", "8")])
      ]
  }
