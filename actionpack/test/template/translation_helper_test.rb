require 'abstract_unit'

class TranslationHelperTest < ActiveSupport::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TranslationHelper

  attr_reader :request

  def setup
    I18n.backend.store_translations(:en,
      :translations => {
        :foo => 'Foo',
        :bar => 'Bar',
        :hello => '<a>Hello World</a>',
        :html => '<a>Hello World</a>',
        :hello_html => '<a>Hello World</a>',
        :interpolated_html => '<a>Hello %{word}</a>',
        :array_html => %w(foo bar),
        :array => %w(foo bar)
      }
    )
  end

  def test_delegates_to_i18n_setting_the_raise_option
    I18n.expects(:translate).with('foo', :locale => 'en', :raise => true).returns("")
    translate :foo, :locale => 'en'
  end

  def test_returns_missing_translation_message_wrapped_into_span
    expected = '<span class="translation_missing">en, foo</span>'
    assert_equal expected, translate(:foo)
  end

  def test_translation_returning_an_array
    assert_equal ["foo", "bar"], translate('translations.array')
  end

  def test_translation_of_an_array
    assert_deprecated do
      assert_equal ["Foo", "Bar"], translate(["translations.foo", "translations.bar"])
    end
  end

  def test_translation_of_an_array_returning_an_array
    assert_deprecated do
      assert_equal ["Foo", ["foo", "bar"]], translate(["translations.foo", "translations.array"])
    end
  end

  def test_translation_of_an_array_with_html
    assert_deprecated do
      @view = ActionView::Base.new(ActionController::Base.view_paths, {})
      expected = '<a>Hello World</a>, <a>Hello World</a>, <a>Hello World</a>'
      assert_equal expected, @view.render(:file => "test/array_translation")
    end
  end

  def test_delegates_localize_to_i18n
    @time = Time.utc(2008, 7, 8, 12, 18, 38)
    I18n.expects(:localize).with(@time)
    localize @time
  end

  def test_scoping_by_partial
    I18n.expects(:translate).with("test.translation.helper", :raise => true).returns("helper")
    @view = ActionView::Base.new(ActionController::Base.view_paths, {})
    assert_equal "helper", @view.render(:file => "test/translation")
  end

  def test_scoping_by_partial_of_an_array
    assert_deprecated do
      I18n.expects(:translate).with("test.scoped_array_translation.foo", :raise => true).returns("foo")
      I18n.expects(:translate).with("test.scoped_array_translation.bar", :raise => true).returns("bar")
      @view = ActionView::Base.new(ActionController::Base.view_paths, {})
      # the view will call translate with unqualified keys, e.g. translate(".foo")
      assert_equal "foo, bar", @view.render(:file => "test/scoped_array_translation")
    end
  end

  def test_translate_works_with_symbols
    assert_equal "Foo", translate(:'translations.foo')
  end


  def test_translate_does_not_mark_plain_text_as_safe_html
    assert_equal false, translate("translations.hello").html_safe?
  end

  def test_translate_marks_translations_named_html_as_safe_html
    assert translate("translations.html").html_safe?
  end

  def test_translate_marks_translations_with_a_html_suffix_as_safe_html
    assert translate("translations.hello_html").html_safe?
  end

  def test_translate_escapes_interpolations_in_translations_with_a_html_suffix_with_xss_protection
    ActionView::Base.expects(:xss_safe?).at_least_once.returns(true)
    assert_equal '<a>Hello &lt;World&gt;</a>', translate('translations.interpolated_html', :word => '<World>')
    assert_equal '<a>Hello &lt;World&gt;</a>', translate('translations.interpolated_html', :word => stub(:to_s => "<World>"))
  end

  def test_translate_does_not_escape_interpolations_in_translations_with_a_html_suffix_without_xss_protection
    ActionView::Base.expects(:xss_safe?).at_least_once.returns(false)
    assert_equal '<a>Hello <World></a>', translate('translations.interpolated_html', :word => '<World>')
  end

  def test_translation_returning_an_array_ignores_html_suffix
    assert_equal ["foo", "bar"], translate('translations.array_html')
  end

end
