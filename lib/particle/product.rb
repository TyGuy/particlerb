require 'particle/model'

module Particle

  # Domain model for one Particle device
  class Product < Model
    ID_REGEX = /^\d{1,5}$/

    def initialize(client, attributes)
      super(client, attributes)

      attributes = attributes.to_s if attributes.is_a?(Integer)

      if attributes.is_a? String
        if attributes =~ ID_REGEX
          @attributes = { id: attributes }
        else
          @attributes = { slug: attributes }
        end
      else
        # Listing all devices returns partial attributes so check if the
        # device was fully loaded or not
        @fully_loaded = true if attributes.key?(:name)
      end
    end

    # NOTE: the key :requires_activation_codes is documented (as of 2018/05/19)
    # but does not seem to come through in the response for product requests,
    # so excluding it for now.
    attribute_reader :name, :description, :platform_id, :type, :hardware_version,
      :config_id, :organization

    def get_attributes
      @loaded = @fully_loaded = true
      @attributes = @client.product_attributes(self)
    end

    def id
      get_attributes unless @attributes[:id]
      @attributes[:id]
    end

    def slug
      get_attributes unless @attributes[:slug]
      @attributes[:slug]
    end

    def id_or_slug
      @attributes[:id] || @attributes[:slug]
    end

    def self.list_path
      "v1/products"
    end

    def path
      "/v1/products/#{id_or_slug}"
    end
  end
end
