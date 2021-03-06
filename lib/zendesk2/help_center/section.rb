# frozen_string_literal: true
class Zendesk2::HelpCenter::Section
  include Zendesk2::Model

  extend Zendesk2::Attributes

  # @return [Integer] Automatically assigned when creating subscriptions
  identity :id, type: :integer

  # @return [Integer] The id of the category to which this section belongs
  attribute :category_id, type: :integer # ro:no required:no
  # @return [Time] The time at which the section was created
  attribute :created_at, type: :time # ro:yes required:no
  # @return [String] The description of the section
  attribute :description, type: :string # ro:no required:no
  # @return [String] The url of this section in HC
  attribute :html_url, type: :string # ro:yes required:no
  # @return [String] The locale in which the section is displayed
  attribute :locale, type: :string # ro:no required:yes
  # @return [String] The name of the section
  attribute :name, type: :string # ro:no required:yes
  # @return [Boolean] Whether the section is out of date
  attribute :outdated, type: :boolean # ro:yes required:no
  # @return [Integer] The position of this section in the section list. By default the section is added to the end of
  #   the list
  attribute :position, type: :integer # ro:no required:no
  # @return [String] The sorting of articles within this section. By default it's set to manual. See sorting below.
  attribute :sorting, type: :string # ro:no required:no
  # @return [String] The source (default) locale of the section
  attribute :source_locale, type: :string # ro:yes required:no
  # @return [Array] The ids of all translations of this section
  attribute :translation_ids, type: :array # ro:yes required:no
  # @return [Time] The time at which the section was last updated
  attribute :updated_at, type: :time # ro:yes required:no
  # @return [string] The API url of this section
  attribute :url, type: :string # ro:yes required:no

  # @return [Zendesk2::HelpCenter::Category] category containing this section
  assoc_accessor :category, collection: :help_center_categories

  def destroy!
    requires :identity

    cistern.destroy_help_center_section('section' => { 'id' => identity })
  end

  def save!
    response = if new_record?
                 requires :name, :locale, :category_id

                 cistern.create_help_center_section('section' => attributes)
               else
                 requires :identity

                 cistern.update_help_center_section('section' => attributes)
               end

    merge_attributes(response.body['section'])
  end

  def articles
    requires :identity

    cistern.help_center_articles(section_id: identity)
  end

  def access_policy
    requires :identity

    response = cistern.get_help_center_access_policy(section_id: identity).body['access_policy']
    response['section_id'] = identity

    cistern.help_center_access_policy(response)
  end

  def subscriptions
    requires :identity

    cistern.help_center_subscriptions(content_id: identity, content_type: 'section')
  end

  def translations
    requires :identity

    cistern.help_center_translations(source_id: identity, source_type: 'Section')
  end
end
