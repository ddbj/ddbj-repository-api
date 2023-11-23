module PathnameWithin
  refine Pathname do
    def within?(path)
      expand_path.to_s.start_with?(path.expand_path.to_s)
    end
  end
end
