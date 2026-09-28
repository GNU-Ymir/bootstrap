[{
   "code" : "E4125",
   "data" : {
          "fixes" : [{
                  "edit" : {
                         "changes" : {
                                   "file://$ROOT/test_resources/lsp/test3.yr" : [{
                                                                              "newText" : "expand",
                                                                              "range" : {
                                                                                      "end" : {
                                                                                            "character" : 15,
                                                                                            "line" : 5
                                                                                      },
                                                                                      "start" : {
                                                                                              "character" : 10,
                                                                                              "line" : 5
                                                                                      }
                                                                              }
                                   }, {
                                                                              "newText" : "alias",
                                                                              "range" : {
                                                                                      "end" : {
                                                                                            "character" : 22,
                                                                                            "line" : 5
                                                                                      },
                                                                                      "start" : {
                                                                                              "character" : 16,
                                                                                              "line" : 5
                                                                                      }
                                                                              }
                                   }]
                         }
                  },
                  "kind" : "quickfix",
                  "title" : "invert the two keywords"
          }]
   },
   "message" : "cannot alias an expand value, maybe alias and expand keywords are inverted?",
   "range" : {
           "end" : {
                 "character" : 22,
                 "line" : 5
           },
           "start" : {
                   "character" : 10,
                   "line" : 5
           }
   },
   "relatedInformation" : [{
                        "location" : {
                                   "range" : {
                                           "end" : {
                                                 "character" : 7,
                                                 "line" : 3
                                           },
                                           "start" : {
                                                   "character" : 3,
                                                   "line" : 3
                                           }
                                   },
                                   "uri" : "file://$ROOT/test_resources/lsp/test3.yr"
                        },
                        "message" : "when validating test3::main"
   }],
   "severity" : 1,
   "source" : "ymirc"
}]
