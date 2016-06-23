class Chemical < ApplicationRecord

  # ----------- Connect Database Part -------------
  establish_connection(
    adapter: "mysql2",
    host: "localhost",
    username: "root",
    database: "whmall_rails5_development"
  )
  self.table_name = "chemicals"

  # ----------- Acts As Followable Part -------------
  # 化学品可以被关注
  acts_as_followable

  # ----------- Elasticsearch Part -------------
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name 'typeahead_es_demo'
  document_type 'chemicals'

  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mapping do
      indexes :cas, type: 'string', index: "not_analyzed", analyzer: 'snowball'
      indexes :name, type: 'string', analyzer: 'snowball'
      indexes :alias_name, type: 'string', analyzer: 'snowball'
      indexes :name_cn, type: 'string', analyzer: 'ik_smart'
      indexes :alias_name_cn, type: 'string', analyzer: 'ik_smart'

      indexes :suggest, type: 'completion', analyzer: 'snowball'
    end
  end

  def as_indexed_json(options = {})
    {
      cas: self.title.to_s.strip,
      remark: self.remark.to_s.strip
    }
  end

  def self.search(q, page = 1, page_size = 20)
    query = {
      bool: {
        must: [
          { term: { } }
        ],
      }
    }
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['title', 'remark^2'],
            type: 'phrase'
          }
        },
        min_score: 0.20,
        size: page_size,
        from: (page - 1) * page_size,
        highlight: {
          pre_tags: ['<em class="label label-highlight">'],
          post_tags: ['</em>'],
          fields: {
            title:   { number_of_fragments: 0 },
            content: { fragment_size: 25 }
          }
        }
      }
    )
  end

  # ----------- Connect Database Part -------------
end
