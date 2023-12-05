class Request < ApplicationRecord
  belongs_to :dway_user,  optional: true
  belongs_to :submission, optional: true

  has_many :objs, dependent: :destroy do
    def base
      find { _1._id == '_base' }
    end
  end

  enum :status, %w(waiting processing finished).index_by(&:to_sym)

  validates :db, inclusion: {in: DB.map { _1[:id] }}

  def validity
    return nil unless finished?

    if objs.any?(&:validity_error?)
      'error'
    elsif objs.any?(&:validity_invalid?)
      'invalid'
    else
      'valid'
    end
  end

  def validation_reports
    objs.map(&:validation_report)
  end

  def write_files_to_tmp(only: nil, &block)
    Dir.mktmpdir {|tmpdir|
      tmpdir = Pathname.new(tmpdir)

      objs.without_base.each do |obj|
        next if only && obj._id != only

        path = tmpdir.join(obj.path)
        path.dirname.mkpath

        obj.file.open do |file|
          FileUtils.mv file.path, path
        end
      end

      block.call tmpdir
    }
  end

  def write_submission_files(to:)
    to.tap(&:mkpath).join('validation-report.json').write JSON.pretty_generate(validation_reports)

    objs.each do |obj|
      obj_dir = to.join(obj._id)

      if obj.base?
        obj_dir.mkpath
        obj_dir.join('validation-report.json').write JSON.pretty_generate(obj.validation_report)
      else
        path = obj_dir.join(obj.path)
        path.dirname.mkpath

        obj.file.open do |file|
          FileUtils.mv file.path, path
        end

        File.write "#{path}-validation-report.json", JSON.pretty_generate(obj.validation_report)
      end
    end
  end
end
