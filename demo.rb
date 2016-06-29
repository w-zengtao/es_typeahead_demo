这个是mapping {
  "tweet": {
    "type": "string",
    "analyzer": "englist",
    "fields": {
      "raw": {
        "type": "string",
        "index": "not_analyzed"
      }
    }
  }
}

{
  "query": {
    "match": {
      "tweet": "Elasticsearch"
    }
  },
  "sort": "tweet.raw"
}
{
  "query": {
    "filtered": {
      "query": {
        "match": {
          "tweet": "manage text search"
        }
      },
      "filter": {
        "term": { "user_id": 1 }
      }
    },
    "sort": [
      { "date": { "order": "desc" }},
      { "_score": { "order": "desc" } }
    ]
  }
}

{
  "query": {
    "filtered": {
      "filter": {
        "bool": {
          "must": { "term": { "folder": "inbox" }},
          "must_not": {
            "query": {
              "match": { "email": "urgent business proposal" }
            }
          }
        }
      }
    }
  }
}

{
  "query": {
    "filtered": {
      "query": {
        "match": { "email": 'business opportunity' }
      },
      "filter": {
        "term": { "folder": "inbox" }
      }
    }
  }
}

{
  "query": {
    "match_all": { }
  }
}
{
  "query": {
    "match": {
      "tweet": "Elasticsearch"
    }
  }
}

{
  "query": {
    "bool": {
      "must": {
        "match": {
          "tweet": "Elasticsearch"
        }
      },
      "must_not": {

      },
      "should": [
        {
          "match": {

          }
        }
      ],
    }
  }
}

{
  "bool": {
    "must": {
      "match": {
        "email": "business opportunity"
      }
    },
    "should": [
      {
        "match": {
          "starred": true
        }
      },
      {
        "bool": {
          "must": {
            "folder": 'inbox'
          },
          "must_not": {
            "spam": true
          }
        }
      }
    ],
    "minimum_should_match": 1
  }
}

{
  "term": { "age": 26 },
  "term": { "date": "2014-09-01" }
  "term": { "public": true }
  "term": { "tag": "full_text" }
}
{
  "terms": {
    "tag": ["search", "full_text", "nosql"]
  }
}
{
  "range": {
    "age": {
      "gte": 20,
      "lt": 30
    }
  }
}

# exists 和 missing 过滤可以用于查找文档中是否包含指定字段 或 没有某个字段
{
  "exists": {
    "field": "title"
  }
}
{
  "bool": {
    "must": {
      "term": { "folder": "inbox" }
    },
    "must_not": {
      "term": { "tag": "spam" }
    },
    "should": [
      { "term": { "starred": true }},
      { "term": { "unread": true }}
    ]
  }
}
{
  "bool": {
    "must": {
      "match": { "title": "how to make millons" }
    },
    "must_not": {
      "match": { "tag": "spam" }
    },
    "should": [
      { "match": { "tag": "starred" } },
      { "range": { "data": { "gte": "2014-09-16"} }}
    ]
  }
}

{
  QUERY_NAME: {
    ARGUMENT: VALUE,
    ARGUMENT: VALUE
  }
}

{
  QUERY_NAME: {
    FIELD_NAME: {
      ARGUMENT: VALUE,
      ARGUMENT: VALUE
    }
  }
}
