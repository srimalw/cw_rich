module Rich
  class FilesController < ApplicationController

    before_filter :authenticate_rich_user
    before_filter :set_rich_file, only: [:show, :update, :destroy]

    layout "rich/application"

    def index
      @type = params[:type]
      parent_id = params[:parent_id]
      file_type = params[:file_type] != 'false' ? params[:file_type].split(",").push('folder') : false
      # byebug
      # @items = @type == "image" ? RichFile.images : RichFile.files
      @items = case @type
      when 'image'
        unless file_type
          RichFile.images(parent_id)
        else
          RichFile.images(parent_id).where("rich_file_content_type in (?)", file_type)
        end
      when 'video'
        unless file_type
          RichFile.videos(parent_id)
        else
          RichFile.videos(parent_id).where("rich_file_content_type in (?)", file_type)
        end
      when 'file'
        unless file_type
          RichFile.files(parent_id)
        else
          RichFile.files(parent_id).where("rich_file_content_type in (?)", file_type)
        end
      when 'audio'
        unless file_type
          RichFile.audios(parent_id)
        else
          RichFile.audios(parent_id).where("rich_file_content_type in (?)", file_type)
        end
      else
        unless file_type
          RichFile.any(parent_id)
        else
          RichFile.any(parent_id).where("rich_file_content_type in (?)", file_type)
        end
      end

      if params[:scoped] == 'true'
        @items = @items.where("owner_type = ? AND owner_id = ?", params[:scope_type], params[:scope_id])
      end

      if params[:search].present?
        # @items = @items.where('rich_file_file_name LIKE ?', "%#{params[:search]}%").where.not(simplified_type: 'folder')

        # @items = RichFile.find(255).children

        # @items = @items.each do |item|
        #   if item.children.any?
        #     @items = item.children
        #     continue
        #   else
        #     @items.merge(item)
        #   end
        # end

        @items = @items.where('rich_file_file_name LIKE ?', "%#{params[:search]}%").where.not(simplified_type: 'folder')

        # @items = RichFile.find_by_sql ["WITH RECURSIVE recu AS (
        #                                   SELECT *
        #                                     FROM rich_rich_files
        #                                     WHERE id = ?
        #                                   UNION all
        #                                   SELECT c.*
        #                                     FROM recu p
        #                                     JOIN rich_rich_files c ON c.parent_id = p.id AND c.parent_id != c.id
        #                                 )
        #                                 SELECT * FROM recu WHERE rich_file_file_name LIKE ? ;",parent_id,"%#{params[:search]}%"]
      end

      if params[:alpha] == 'true'
        @items = @items.order("simplified_type ASC")
        @items = @items.order("rich_file_file_name ASC")
      else
        @items = @items.order("created_at DESC")
      end

      @items = @items.page params[:page]

      # stub for new file
      @rich_asset = RichFile.new

      respond_to do |format|
        format.html
        format.js
      end

    end

    def show
      # show is used to retrieve single files through XHR requests after a file has been uploaded

      if(params[:id])
        # list all files
        @file = @rich_file
        render :layout => false
      else
        render :text => "File not found"
      end

    end

    def create

      @file = RichFile.new(:simplified_type => params[:simplified_type])

      if(params[:scoped] == 'true')
        @file.owner_type = params[:scope_type]
        @file.owner_id = params[:scope_id].to_i
      end
      # use the file from Rack Raw Upload
      file_params = params[:file] || params[:qqfile]
      if(file_params)
        file_params.content_type = Mime::Type.lookup_by_extension(file_params.original_filename.split('.').last.to_sym)
        @file.rich_file = file_params
      else
        @file.rich_file_file_name = params[:file_name]
        @file.rich_file_content_type = params[:simplified_type]
      end

      @file.parent_id = params[:parent_id]

      if @file.save
        response = { :success => true, :rich_id => @file.id }
        # byebug
      else
        response = { :success => false,
                     :error => "Could not upload your file:\n- "+@file.errors.to_a[-1].to_s,
                     :params => params.inspect }
      end

      unless @file.simplified_type == 'folder'
        render :json => response, :content_type => "text/html"
        # redirect_to action: 'index', controller: 'rich/files'

      else
        # byebug
        render :json => response, :content_type => "text/html"
        # redirect_to action: 'index', controller: 'rich/files'
      end
    end

    def update
      new_filename_without_extension = params[:filename].parameterize
      if new_filename_without_extension.present?
        new_filename = @rich_file.rename!(new_filename_without_extension)
        render :json => { :success => true, :filename => new_filename, :uris => @rich_file.uri_cache }
      else
        render :nothing => true, :status => 500
      end
    end

    def destroy
      if(params[:id])
        @rich_file.destroy
        @fileid = params[:id]
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_rich_file
        @rich_file = RichFile.find(params[:id])
      end
  end
end
