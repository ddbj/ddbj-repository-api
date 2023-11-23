module PathnameContain
  refine Pathname do
    def contain?(path)
      path.expand_path.to_s.start_with?(expand_path.to_s)
    end
  end
end
