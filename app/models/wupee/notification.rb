class Wupee::Notification < ActiveRecord::Base
  belongs_to :receiver, polymorphic: true
  belongs_to :attached_object, polymorphic: true
  belongs_to :notification_type, class_name: "Wupee::NotificationType"

  validates :receiver, presence: true
  validates :notification_type, presence: true

  scope :read, -> { where(is_read: true) }
  scope :unread, -> { where(is_read: false) }
  scope :wanted, -> { where(is_wanted: true) }
  scope :unwanted, -> { where(is_wanted: false) }
  scope :ordered, -> { order(created_at: :desc) }

  def default_message
    (meta || {})["message"]
  end

  def message_detail
    (meta || {})["detail"]
  end

  def review
    @review ||= ProductReview.find_by_id(parent_id)
  end

  def request
    @request ||= Request.find_by_id(parent_id)
  end

  def actor_name
    meta["actor_name"].presence
  end

  def actor_avatar_url
    meta["actor_avatar_url"].presence || Settings.placeholders.avatar
  end

  def owner_review_path
    meta["owner_review_path"]
  end

  def review_title
    "review sách #{product_name}"
  end

  def product_name
    meta['product_name']
  end

  def img_src
    meta["img_src"].presence || Settings.placeholders.list_book
  end

  def mark_as_read
    update_columns(is_read: true)
  end

  def mark_as_sent
    update_columns(is_sent: true)
  end
end
