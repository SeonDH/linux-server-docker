require 'kramdown'
require 'fileutils'
require 'cgi'
root = __dir__
out = File.join(root, 'docs')
FileUtils.mkdir_p(out)
# Remove a previously published page excluded from this learner edition.
FileUtils.rm_f(File.join(out, 'instructor.html'))
groups = {
  '교육 안내' => %w[index guide setup],
  '보충 학습' => %w[01-resources 02-docker 03-basics 04-io 05-storage 06-process 07-docker-practice 08-troubleshooting 09-singularity],
  '[실습] 자원 비교' => %w[practice-resources practice-cpu-sharing practice-memory practice-storage-paths],
  '참고 자료' => %w[glossary checklist deep-dive appendix]
}
labels = {
  'index'=>'과정 목차', 'guide'=>'교재 사용 안내', 'setup'=>'0. Docker 설치',
  '01-resources'=>'1. 컴퓨터 자원', '02-docker'=>'2. Docker 개념', '03-basics'=>'3. 경로와 권한',
  '04-io'=>'4. 파일과 파이프', '05-storage'=>'5. 저장공간', '06-process'=>'6. 프로세스와 자원',
  '07-docker-practice'=>'7. Docker 파일 연결', '08-troubleshooting'=>'8. 트러블슈팅', '09-singularity'=>'9. Singularity 이해',
  'practice-resources'=>'[실습] 자원 관찰', 'practice-cpu-sharing'=>'[실습] CPU 공유', 'practice-memory'=>'[실습] 메모리 부족', 'practice-storage-paths'=>'[실습] 저장 위치와 공간 부족',
  'glossary'=>'핵심 용어', 'checklist'=>'작업 체크리스트', 'deep-dive'=>'[번외] 더 알고 싶을 때',
  'appendix'=>'보충 학습 링크'
}
order=groups.values.flatten
basic=%w[index guide setup 01-resources 02-docker 03-basics 04-io 05-storage 06-process 07-docker-practice 08-troubleshooting 09-singularity]
order.each do |name|
  text=File.read(File.join(root,'content',name+'.md'))
  title=text.lines.first.sub(/^# /,'').strip
  text=text.lines.each_with_index.map { |line,i| line.start_with?('|') && i>0 && !text.lines[i-1].start_with?('|') ? "\n"+line : line }.join
  body=Kramdown::Document.new(text.gsub('```','~~~').gsub("\n~~~","\n\n~~~"), input:'kramdown',syntax_highlighter:nil).to_html
  nav=groups.map do |group,items|
    '<div class="nav-group">'+CGI.escapeHTML(group)+'</div>'+items.map { |item| %Q{<a #{item==name ? 'aria-current="page"' : ''} href="#{item}.html">#{CGI.escapeHTML(labels[item])}</a>} }.join
  end.join
  headings=body.scan(/<h2 id="([^"]+)">(.*?)<\/h2>/m)
  toc=''
  unless headings.empty? || name=='deep-dive'
    toc='<details class="toc"><summary>이 페이지 목차</summary><ul>'+headings.map { |id,label| '<li><a href="#'+id+'">'+label.gsub(/<[^>]+>/,'')+'</a></li>' }.join+'</ul></details>'
    body=body.sub(/(<h1[^>]*>.*?<\/h1>)/m) { |h| h+toc }
  end
  sequence=basic.include?(name) ? basic : groups.values.find { |items| items.include?(name) }
  idx=sequence.index(name)
  previous=idx>0 ? %Q{<a href="#{sequence[idx-1]}.html">← #{CGI.escapeHTML(labels[sequence[idx-1]])}</a>} : '<span></span>'
  following=idx<sequence.length-1 ? %Q{<a href="#{sequence[idx+1]}.html">#{CGI.escapeHTML(labels[sequence[idx+1]])} →</a>} : '<a href="index.html">과정 목차로 돌아가기</a>'
  page=<<~HTML
    <!doctype html><html lang="ko"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>#{CGI.escapeHTML(title)} | 리눅스 응용 보충 과정</title><link rel="stylesheet" href="assets/style.css"></head>
    <body><a class="skip" href="#main-content">본문으로 건너뛰기</a><aside><a class="brand" href="index.html">리눅스 응용<br>보충 과정</a><p class="subtitle">핵심 기초 복습과<br>Docker·Singularity 활용</p><nav aria-label="교재 전체 목차">#{nav}</nav><a class="old" href="https://seondh.github.io/bio_linux/">기존 바이오 리눅스 교재 ↗</a></aside><main id="main-content"><div class="eyebrow">바이오 리눅스 후속 교육 · 이해와 작은 실습</div><article>#{body}</article><footer>#{previous}#{following}</footer><p class="context-note">리눅스 응용 보충 과정 · 개인 실습 폴더와 자신의 작업을 확인한다.</p></main><script src="assets/app.js"></script></body></html>
  HTML
  File.write(File.join(out,name+'.html'),page)
end
FileUtils.cp_r(File.join(root,'assets'),out)
FileUtils.cp_r(File.join(root,'labs'),out)
File.write(File.join(out,'.nojekyll'),'')
puts "Built #{order.size} pages in docs/"
