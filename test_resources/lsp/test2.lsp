[{
   "code" : "E4075",
   "data" : {
          "fixes" : [{
                  "edit" : {
                         "changes" : {
                                   "file://$ROOT/test_resources/lsp/test2.yr" : [{
                                                                              "newText" : "copy",
                                                                              "range" : {
                                                                                      "end" : {
                                                                                            "character" : 17,
                                                                                            "line" : 8
                                                                                      },
                                                                                      "start" : {
                                                                                              "character" : 12,
                                                                                              "line" : 8
                                                                                      }
                                                                              }
                                   }]
                         }
                  },
                  "kind" : "quickfix",
                  "title" : "replace dcopy by the simple copy operator"
          }]
   },
   "message" : "using a deep copy instead of a one level copy is prohibited when enclosing a record",
   "range" : {
           "end" : {
                 "character" : 19,
                 "line" : 8
           },
           "start" : {
                   "character" : 18,
                   "line" : 8
           }
   },
   "relatedInformation" : [{
                        "location" : {
                                   "range" : {
                                           "end" : {
                                                 "character" : 7,
                                                 "line" : 6
                                           },
                                           "start" : {
                                                   "character" : 3,
                                                   "line" : 6
                                           }
                                   },
                                   "uri" : "file://$ROOT/test_resources/lsp/test2.yr"
                        },
                        "message" : "when validating test2::main"
   }],
   "severity" : 1,
   "source" : "ymirc"
}]
