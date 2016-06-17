class Article < ApplicationRecord

  include Elasticsearch::Model
  index_name 'typeahead_es_demo'

  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mapping do
      indexes :title, analyzer: "snowball"
      indexes :remark, analyzer: "snowball"
    end
  end

  def self.search(query)
      __elasticsearch__.search(
        {
          query: {
            multi_match: {
              query: query,
              fields: ['title', 'remark^2'],
              type: 'phrase'
            }
          },
          size: 20,
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


  class << self

    def reset_es_data
      Article.__elasticsearch__.client.indices.delete index: Article.index_name if Article.__elasticsearch__.client.indices.exists? index: Article.index_name
      Article.__elasticsearch__.client.indices.create index: Article.index_name
      Article.find_each do |a|
        a.__elasticsearch__.index_document
      end
    end

    def init
      (1..100).each do |index|
        Article.create(title: random_title, author_id: random_author_id, remark: random_remark)
      end
      reset_es_data
    end

    def origin_data
      @origin_data = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
          'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii',
          'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
          'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
          'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
          'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota',
          'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island',
          'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
          'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
      ].to_a
    end
    def random_title
      @origin_data ||= origin_data
      @origin_data.shuffle.last(3).join(' ')
    end

    def random_author_id
      rand(50)
    end

    def random_remark
      @origin_data ||= origin_data
      @origin_data.shuffle.last(3).join(' ')
    end

    def random_content
    end
  end
end
