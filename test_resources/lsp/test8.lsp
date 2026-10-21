[{
   "code" : "E4226",
   "data" : {
          "fixes" : [{
                  "edit" : {
                         "changes" : {
                                   "file://$ROOT/test_resources/lsp/test8.yr" : [{
                                                                              "newText" : "ref ",
                                                                              "range" : {
                                                                                      "end" : {
                                                                                            "character" : 10,
                                                                                            "line" : 7
                                                                                      },
                                                                                      "start" : {
                                                                                              "character" : 10,
                                                                                              "line" : 7
                                                                                      }
                                                                              }
                                   }]
                         }
                  },
                  "kind" : "quickfix",
                  "title" : "reference it explicitly with ref"
          }]
   },
   "message" : "the call operator is not defined for test8::take (mut ref x: mut i32)-> void and {y: mut i32}\ncandidate test8::take (mut ref x: mut i32)-> void\nfor parameter mut ref x: mut i32",
   "range" : {
           "end" : {
                 "character" : 10,
                 "line" : 7
           },
           "start" : {
                   "character" : 9,
                   "line" : 7
           }
   },
   "relatedInformation" : [{
                        "location" : {
                                   "range" : {
                                           "end" : {
                                                 "character" : 11,
                                                 "line" : 7
                                           },
                                           "start" : {
                                                   "character" : 10,
                                                   "line" : 7
                                           }
                                   },
                                   "uri" : "file://$ROOT/test_resources/lsp/test8.yr"
                        },
                        "message" : "cannot pass value of type mut i32 as ref"
   }, {
                        "location" : {
                                   "range" : {
                                           "end" : {
                                                 "character" : 7,
                                                 "line" : 5
                                           },
                                           "start" : {
                                                   "character" : 3,
                                                   "line" : 5
                                           }
                                   },
                                   "uri" : "file://$ROOT/test_resources/lsp/test8.yr"
                        },
                        "message" : "when validating test8::main"
   }],
   "severity" : 1,
   "source" : "ymirc"
}]
