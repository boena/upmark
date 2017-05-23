RSpec.describe Upmark::Transform::Markdown do
  def transform(ast)
    Upmark::Transform::Markdown.new.apply(ast)
  end

  let(:transformed_ast) { transform(ast) }

  context "#apply" do
    context '<br>' do
      let(:ast) { [{ element: { name: 'br' }}] }

      it 'will transform to markdown' do
        expect(transformed_ast).to eq ["\n"]
      end
    end

    context "<h1>" do
      let(:ast) do
        [
          {
            element: {
              name: "h1",
              attributes: [],
              children: [{text: "heading test"}],
              ignore: false
            }
          }
        ]
      end

      it 'transforms to correct markdown' do
        expect(
          transformed_ast
        ).to eq(["# heading test\n"])
      end
    end

    context "<p>" do
      context "single tag" do
        let(:ast) do
          [
            {
              element: {
                name: "p",
                attributes: [],
                children: [{text: "messenger bag skateboard"}],
                ignore: false
              }
            }
          ]
        end

        it 'transforms to markdown' do
          expect(
            transformed_ast
          ).to eq(["messenger bag skateboard\n\n"])
        end
      end

      context "multiple tags" do
        let(:ast) do
          [
            {
              element: {
                name: "p",
                attributes: [],
                children: [{text: "messenger"}],
                ignore: false
              }
            }, {
              element: {
                name: "p",
                attributes: [],
                children: [{text: "bag"}],
                ignore: false
              }
            }, {
              element: {
                name: "p",
                attributes: [],
                children: [{text: "skateboard"}],
                ignore: false
              }
            }
          ]
        end

        it 'transforms to markdown' do
          expect(
            transformed_ast
          ).to eq(["messenger\n\n", "bag\n\n", "skateboard\n\n"])
        end
      end
    end

    context "<a>" do
      context "single tag" do
        let(:ast) do
          a_tag(
            href: "http://helvetica.com/",
            title: "art party organic",
          )
        end

        def a_tag(attributes)
          [
            {
              element: {
                name: "a",
                attributes: attributes.map do |key, value|
                  { name: key.to_s, value: value }
                end,
                children: [{text: "messenger bag skateboard"}],
                ignore: false
              }
            }
          ]
        end

        it 'transforms to markdown' do
          expect(
            transformed_ast
          ).to eq([%q{[messenger bag skateboard](http://helvetica.com/ "art party organic")}])
        end

        it 'transforms mailto to markdown' do
          expect(
            transform a_tag(href: 'mailto:a@example.com', title: 'Some Path')
          ).to eq([%q{[messenger bag skateboard](mailto:a@example.com "Some Path")}])
        end

        it 'strips local urls to their text' do
          expect(
            transform a_tag(href: 'file://some/path', title: 'Some Path')
          ).to eq ['messenger bag skateboard']
        end

        it 'strips relative urls to their alt text' do
          expect(
            transform a_tag(src: 'some/path', title: 'Some Path')
          ).to eq ['messenger bag skateboard']
        end
      end
    end

    context "<img>" do
      context "empty tag" do
        let(:ast) do
          img(
            src:   "http://helvetica.com/image.gif",
            title: "art party organic",
            alt:   "messenger bag skateboard",
          )
        end

        def img(attributes)
          [
            {
              element: {
                name: "img",
                attributes: attributes.map do |key, value|
                  { name: key.to_s, value: value }
                end,
                children: [],
                ignore: false
              }
            }
          ]
        end

        it 'transforms to markdown' do
          expect(
            transformed_ast
          ).to eq([%q{![messenger bag skateboard](http://helvetica.com/image.gif "art party organic")}])
        end

        it 'strips file urls to their alt text or title' do
          expect(
            transform img(src: 'file://some/path', alt: 'Some', title: 'Path')
          ).to eq ['Some']
          expect(
            transform img(src: 'file://some/path', title: 'Some Path')
          ).to eq ['Some Path']
        end

        it 'strips relative urls to their alt text' do
          expect(
            transform img(src: 'some/path', alt: 'Some', title: 'Path')
          ).to eq ['Some']
          expect(
            transform img(src: 'some/path', title: 'Some Path')
          ).to eq ['Some Path']
        end
      end
    end
  end
end
