# -*- coding: utf-8 -*-
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # コードのシンタックスハイライトを行うための JavaScript のライブラリ
  # を読み込むための HTML を取得する。
  #
  # 次の引数を取る。
  # name::      シンタックスハイライトする DOM の name 属性を指定する。
  # languages:: シンタックスハイライト対象の言語を指定する。
  def syntax_highlighter_include_tag(name, *languages)
    stylesheet = stylesheet_link_tag("SyntaxHighlighter")
    javascripts = [javascript_include_tag("shCore")]
    javascripts << languages.map { |e|
      javascript_include_tag("shBrush#{e.capitalize}")
    }
    @onload_javascript ||= ""
    @onload_javascript << <<EOS
dp.SyntaxHighlighter.ClipboardSwf = '/javascripts/clipboard.swf';
dp.SyntaxHighlighter.HighlightAll('#{name}');
EOS
    return [stylesheet, javascripts].join("\n")  
  end

  # program で指定したサンプルプログラムに対して、シンタックスハイライ
  # トなどを行うように HTML のタグを付加する。
  def code(program)
    return '<pre name="code" class="ruby">' + h(program) + '</pre>'
  end
end
