[{
   "code" : "E4226",
   "data" : {
          "fixes" : [{
                  "edit" : {
                         "changes" : {
                                   "file://$ROOT/test_resources/lsp/test9.yr" : [{
                                                                              "newText" : "alias ",
                                                                              "range" : {
                                                                                      "end" : {
                                                                                            "character" : 10,
                                                                                            "line" : 5
                                                                                      },
                                                                                      "start" : {
                                                                                              "character" : 10,
                                                                                              "line" : 5
                                                                                      }
                                                                              }
                                   }]
                         }
                  },
                  "kind" : "quickfix",
                  "title" : "borrow it explicitly with alias"
          }]
   },
   "message" : "the call operator is not defined for test9::take (mut _: mut [mut i32])-> void and {t.0: mut [mut i32]}\ncandidate test9::take (mut _: mut [mut i32])-> void\nfor parameter mut _: mut [mut i32]",
   "range" : {
           "end" : {
                 "character" : 10,
                 "line" : 5
           },
           "start" : {
                   "character" : 9,
                   "line" : 5
           }
   },
   "relatedInformation" : [{
                        "location" : {
                                   "range" : {
                                           "end" : {
                                                 "character" : 12,
                                                 "line" : 5
                                           },
                                           "start" : {
                                                   "character" : 11,
                                                   "line" : 5
                                           }
                                   },
                                   "uri" : "file://$ROOT/test_resources/lsp/test9.yr"
                        },
                        "message" : "discarding the constant property is prohibited"
   }, {
                        "location" : {
                                   "range" : {
                                           "end" : {
                                                 "character" : 12,
                                                 "line" : 5
                                           },
                                           "start" : {
                                                   "character" : 11,
                                                   "line" : 5
                                           }
                                   },
                                   "uri" : "file://$ROOT/test_resources/lsp/test9.yr"
                        },
                        "message" : "implicit alias of type mut [mut i32] is prohibited, it implicitly gives up on borrowings of mutable values"
   }, {
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
                                   "uri" : "file://$ROOT/test_resources/lsp/test9.yr"
                        },
                        "message" : "when validating test9::main"
   }],
   "severity" : 1,
   "source" : "ymirc"
}]
