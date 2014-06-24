Pod::Spec.new do |s|
  s.name           = 'BDGWebviewVC'
  s.version        = '0.0.2'
  s.summary        = 'Webview-based ViewController'
  s.license 	   = 'MIT'
  s.description    = 'Webview-based ViewController including navigation buttons and many configurable properties'
  s.homepage       = 'https://github.com/BobDG/BDGWebviewVC'
  s.authors        = {'Bob de Graaf' => 'graafict@gmail.com'}
  s.source         = { :git => 'https://github.com/BobDG/BDGWebviewVC.git', :tag => '0.0.2' }
  s.source_files   = '*.{h,m}'  
  s.resources      = ['**/*.{png}', '**/*.lproj']
  s.platform       = :ios
  s.requires_arc   = true
end
