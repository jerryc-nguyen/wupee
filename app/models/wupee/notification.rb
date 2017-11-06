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

  def self.last_notification_for(receiver_id: nil, receiver_type: "User",
    attached_object_type: nil, noti_type: nil, request_id: nil,
    attached_object_id: nil, notification_type_id: nil,
    parent_id: nil, parent_type: nil
    )

    condition = {
      receiver_id: receiver_id,
      receiver_type: receiver_type,
      attached_object_type: attached_object_type
    }

    if attached_object_id.present?
      condition[:attached_object_id] = attached_object_id
    end

    if notification_type_id.present?
      condition[:notification_type_id] = notification_type_id
    end

    if parent_id.present?
      condition[:parent_id] = parent_id
    end

    if parent_type.present?
      condition[:parent_type] = parent_type
    end

    relation = where(condition)

    case noti_type
    when :comment_request
      join_sql = <<-SQL
        JOIN comments com ON com.id = attached_object_id AND attached_object_type = 'Comment'
          AND com.commentable_type='Request' AND com.commentable_id = '#{request_id}'
      SQL
      relation = relation.joins(join_sql)
    end
    relation.order(updated_at: :desc).first
  end

  def review
    @review ||= ProductReview.find_by_id(parent_id)
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
