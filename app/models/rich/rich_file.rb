require 'cgi'
require 'mime/types'
require 'kaminari'

module Rich
  class RichFile < ActiveRecord::Base
		include Backends::Paperclip
    scope :images,  -> (id) { where(simplified_type: 'image',simplified_type: 'folder',parent_id: id)
			# where("rich_rich_files.simplified_type = 'image' and rich_rich_files.simplified_type = 'folder'")
    }
    scope :videos,   -> (id) { where(simplified_type: 'video',simplified_type: 'folder',parent_id: id)
			# where("rich_rich_files.simplified_type = 'video' and rich_rich_files.simplified_type = 'folder'")
    }
    scope :files,   -> (id) { where(simplified_type: 'file',simplified_type: 'folder',parent_id: id)
			# where("rich_rich_files.simplified_type = 'file' and rich_rich_files.simplified_type = 'folder'")
    }
    scope :audios,   -> (id) { where(simplified_type: 'audio',simplified_type: 'folder') }
    scope :any,   -> (id) { where(parent_id: id) }

    paginates_per Rich.options[:paginates_per]
  end
end
