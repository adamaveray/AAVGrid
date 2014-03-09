Pod::Spec.new do |s|
  s.name         = "AAVGrid"
  s.version      = "1.0.0"
  s.summary      = "A generic grid storage structure."
  s.description  = <<-DESC
                   A grid storage class to allow storing and retrieving values from coordinates.
                   It abstracts away a multi-dimensional array, ensuring all sub-arrays are the
                   correct size, and allowing abstracted access to the values through blocks, etc.
                   DESC
  s.homepage     = "https://github.com/adamaveray/AAVGrid"
  s.license      = 'MIT'

  s.author             = { "Adam Averay" => "adam@averay.com" }
  s.social_media_url   = "http://twitter.com/adamaveray"

  s.source        = { :git => "https://github.com/adamaveray/AAVGrid.git", :tag => "1.0.0" }
  s.source_files  = 'AAVGrid', 'AAVGrid/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.requires_arc  = true
end
