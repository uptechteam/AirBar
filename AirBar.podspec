Pod::Spec.new do |spec|
  spec.name = "AirBar"
  spec.version = "2.0.6"
  spec.summary = "Airbnb expandable bar."
  spec.homepage = "https://github.com/uptechteam/AirBar"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Evgeny Matviyenko" => 'evgeny.matviyenko@uptech.team' }

  spec.platform = :ios, "10.0"
  spec.swift_version = "4.1"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/uptechteam/AirBar.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "AirBar/**/*.{h,swift}"
end
