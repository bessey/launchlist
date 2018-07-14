module Checker
  Schema = {
    "$ref" => "#/definitions/check_list",
    "definitions": {
      "check_list" => {
        "type" => "object",
        "required" => ["name", "version", "list"],
        "properties" => {
          "name" => {
            "type" => "string"
          },
          "version" => {
            "type" => "integer"
          },
          "triggers" =>  { "$ref" => "#/definitions/trigger_set" },
          "list" => {
            "type" => "array",
            "items" => {
              "oneOf": [
                { "type" => "string" },
                { "$ref" => "#/definitions/check_set" }
              ]
            }
          }
        },
        "additionalProperties" => false
      },
      "check_set" => {
        "type" => "object",
        "required" => ["category", "checks"],
        "properties" => {
          "category" => {
            "type" => "string"
          },
          "checks" => {
            "type" => "array",
            "items" => {
              "oneOf" => [
                { "type" => "string" },
                { "$ref" => "#/definitions/check" }
              ],
            },
          },
          "triggers" => { "$ref" => "#/definitions/trigger_set" }
        },
        "additionalProperties" => false
      },
      "trigger_set" => {
        "type" => "object",
        "properties" => {
          "paths" => { "$ref" => "#/definitions/string_or_array" },
          "files_include" => { "$ref" => "#/definitions/string_or_array" },
          "changes_include" => { "$ref" => "#/definitions/string_or_array" },
          "additions_include" => { "$ref" => "#/definitions/string_or_array" },
          "deletions_include" => { "$ref" => "#/definitions/string_or_array" },
        },
        "additionalProperties" => false
      },
      "check" => {
        "type" => "object",
        "required" => ["check"],
        "properties" => {
          "check" => {
            "type" => "string"
          },
          "triggers" =>  { "$ref" => "#/definitions/trigger_set" }
        },
        "additionalProperties" => false
      },
      "string_or_array" => {
        "oneOf" => [
          {"type" => "string"},
          {
            "type" => "array",
            "items" => {
              "type" => "string"
            }
          }
        ]
      }
    }
  }
end
