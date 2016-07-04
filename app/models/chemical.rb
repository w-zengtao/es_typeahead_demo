class Chemical < ApplicationRecord

  INVALID_UTF8_REGEX = /[\u0000-\u0019]|\u200b/
  WHITESPACE_REGEXP = /\u001f/

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
    mappings do
      indexes :cas, type: 'string', index: "not_analyzed", analyzer: 'snowball'
      indexes :status, type: 'integer'
      indexes :names, type: 'string', analyzer: 'snowball'
      indexes :keyword_suggest, type: 'completion',  payloads: true
    end
  end

  def as_indexed_json(options = {})
    {
      cas: self.cas.to_s.strip,
      names: self.suggests,
      status: self.status.to_i,
      keyword_suggest: {
        input: self.suggests
      }
    }.as_json
  end

  def suggests
    s = []
    s << self.cas
    s << self.name.to_s.downcase.gsub(INVALID_UTF8_REGEX,'').gsub(WHITESPACE_REGEXP,' ').scan(/[a-z]+/).find_all{|i| i.size >= 2}.uniq
    s << self.alias_name.to_s.downcase.gsub(INVALID_UTF8_REGEX,'').gsub(WHITESPACE_REGEXP,' ').scan(/[a-z]+/).find_all{|i| i.size >= 2}.uniq
    s.flatten!
    s.map! {|n| n.to_s.strip.downcase}
    s.select! {|n| n.present?}
    s.uniq
  end

  def self.typeahead(query)
    Chemical.__elasticsearch__.client.suggest(
      index: Chemical.index_name,
      body: {
        suggestions: {
          text: query,
          completion: {
            field: 'keyword_suggest'
          }
        }
      }
    )
  end

  def self.search(q, page = 1, page_size = 20)
    query = {
      bool: {
        must: [
          { term: { status: {value: 0} } }
        ],
        should: [
          { match: { names: q }}
        ]
      }
    }
    __elasticsearch__.search(
      {
        query: {
          # multi_match: {
          #   query: query,
          #   fields: ['title', 'remark^2'],
          #   type: 'phrase'
          # }
          function_score: {
            query: query
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

  def self.remove_es_data
    Chemical.__elasticsearch__.client.indices.delete index: Chemical.index_name
  end

  def self.rebuild_es_data
    Chemical.__elasticsearch__.client.indices.create index: Chemical.index_name
    Chemical.import
  end

  # ----------- Connect Database Part -------------

end
