describe "a generated stub instance" do
  include FactoryBot::Syntax::Methods

  before do
    define_model("User")

    define_model("Post", title: :string,
                         body: :string,
                         age: :integer,
                         user_id: :integer,
                         draft: :boolean) do
      belongs_to :user
    end

    FactoryBot.define do
      factory :user

      factory :post do
        title { "default title" }
        body { "default body" }
        user
      end
    end
  end

  subject { build_stubbed(:post, title: "overridden title") }

  it "assigns a default attribute" do
    expect(subject.body).to eq "default body"
  end

  it "assigns an overridden attribute" do
    expect(subject.title).to eq "overridden title"
  end

  it "assigns associations" do
    expect(subject.user).to be_kind_of(User)
  end

  it "has an id" do
    expect(subject.id).to be > 0
  end

  it "generates unique ids" do
    other_stub = build_stubbed(:post)
    expect(subject.id).not_to eq other_stub.id
  end

  it "isn't a new record" do
    expect(subject).not_to be_new_record
  end

  it "assigns associations that aren't new records" do
    expect(subject.user).not_to be_new_record
  end

  it "isn't changed" do
    expect(subject).not_to be_changed
  end

  it "disables connection" do
    expect { subject.connection }.to raise_error(RuntimeError)
  end

  it "disables update_attribute" do
    expect { subject.update_attribute(:title, "value") }.to raise_error(RuntimeError)
  end

  it "disables reload" do
    expect { subject.reload }.to raise_error(RuntimeError)
  end

  it "disables destroy" do
    expect { subject.destroy }.to raise_error(RuntimeError)
  end

  it "disables save" do
    expect { subject.save }.to raise_error(RuntimeError)
  end

  it "disables increment!" do
    expect { subject.increment!(:age) }.to raise_error(RuntimeError)
  end

  it "disables decrement!" do
    expect { subject.decrement!(:age) }.to raise_error(RuntimeError)
  end

  it "disables toggle!" do
    expect { subject.toggle!(:draft) }.to raise_error(RuntimeError)
  end

  it "allows increment" do
    subject.age = 1
    subject.increment(:age)
    expect(subject.age).to eq(2)
  end

  it "allows decrement" do
    subject.age = 1
    subject.decrement(:age)
    expect(subject.age).to eq(0)
  end

  it "allows toggle" do
    subject.draft = true
    subject.toggle(:draft)
    expect(subject).not_to be_draft
  end
end

describe "calling `build_stubbed` with a block" do
  include FactoryBot::Syntax::Methods

  before do
    define_model("Company", name: :string)

    FactoryBot.define do
      factory :company
    end
  end

  it "passes the stub instance" do
    build_stubbed(:company, name: "thoughtbot") do |company|
      expect(company.name).to eq("thoughtbot")
      expect { company.save }.to raise_error(RuntimeError)
    end
  end

  it "returns the stub instance" do
    expected = nil
    result = build_stubbed(:company) { |company|
      expected = company
      "hello!"
    }
    expect(result).to eq expected
  end
end

describe "defaulting `created_at`" do
  include FactoryBot::Syntax::Methods

  before do
    define_model("ThingWithTimestamp", created_at: :datetime)
    define_model("ThingWithoutTimestamp")

    FactoryBot.define do
      factory :thing_with_timestamp
      factory :thing_without_timestamp
    end
  end

  it "defaults created_at for objects with created_at" do
    expect(build_stubbed(:thing_with_timestamp).created_at).to be_about_now
  end

  it "is doesn't mark the object as changed" do
    stub = build_stubbed(:thing_with_timestamp)
    expect(stub).not_to be_changed
  end

  it "doesn't add created_at to objects who don't have the method" do
    expect(build_stubbed(:thing_without_timestamp))
      .not_to respond_to(:created_at)
  end

  it "allows overriding created_at for objects with created_at" do
    created_at = 3.days.ago
    stubbed = build_stubbed(:thing_with_timestamp, created_at: created_at)
    expect(stubbed.created_at).to be_within(1.second).of created_at
  end

  it "doesn't allow setting created_at on an object that doesn't define it" do
    expect { build_stubbed(:thing_without_timestamp, created_at: Time.now) }
      .to raise_error(NoMethodError, /created_at=/)
  end

  it "allows assignment of created_at" do
    stub = build_stubbed(:thing_with_timestamp)
    expect(stub.created_at).to be_about_now
    past_time = 3.days.ago
    stub.created_at = past_time
    expect(stub.created_at).to be_within(1.second).of past_time
  end

  it "behaves the same as a non-stubbed created_at" do
    define_model("ThingWithCreatedAt", created_at: :datetime) do
      def created_at
        :the_real_created_at
      end
    end

    FactoryBot.define do
      factory :thing_with_created_at
    end

    stub = build_stubbed(:thing_with_created_at)
    persisted = create(:thing_with_created_at)

    expect(stub.created_at).to eq(persisted.created_at)
  end
end

describe "defaulting `updated_at`" do
  include FactoryBot::Syntax::Methods

  before do
    define_model("ThingWithTimestamp", updated_at: :datetime)
    define_model("ThingWithoutTimestamp")

    FactoryBot.define do
      factory :thing_with_timestamp
      factory :thing_without_timestamp
    end
  end

  it "defaults updated_at for objects with updated_at" do
    expect(build_stubbed(:thing_with_timestamp).updated_at).to be_about_now
  end

  it "is doesn't mark the object as changed" do
    stub = build_stubbed(:thing_with_timestamp)
    expect(stub).not_to be_changed
  end

  it "doesn't add updated_at to objects who don't have the method" do
    expect(build_stubbed(:thing_without_timestamp))
      .not_to respond_to(:updated_at)
  end

  it "allows overriding updated_at for objects with updated_at" do
    past_time = 3.days.ago
    stubbed = build_stubbed(:thing_with_timestamp, updated_at: past_time)
    expect(stubbed.updated_at).to be_within(1.second).of past_time
  end

  it "doesn't allow setting updated_at on an object that doesn't define it" do
    expect {
      build_stubbed(:thing_without_timestamp, updated_at: Time.now)
    }.to raise_error(NoMethodError, /updated_at=/)
  end

  it "allows assignment of updated_at" do
    stub = build_stubbed(:thing_with_timestamp)
    expect(stub.updated_at).to be_about_now
    past_time = 3.days.ago
    stub.updated_at = past_time
    expect(stub.updated_at).to be_within(1.second).of past_time
  end

  it "behaves the same as a non-stubbed updated_at" do
    define_model("ThingWithUpdatedAt", updated_at: :datetime) do
      def updated_at
        :the_real_updated_at
      end
    end

    FactoryBot.define do
      factory :thing_with_updated_at
    end

    stub = build_stubbed(:thing_with_updated_at)
    persisted = create(:thing_with_updated_at)

    expect(stub.updated_at).to eq(persisted.updated_at)
  end
end

describe "defaulting `id`" do
  before do
    define_model("Post")

    FactoryBot.define do
      factory :post
    end
  end

  it "allows overriding id" do
    expect(FactoryBot.build_stubbed(:post, id: 12).id).to eq 12
  end
end

describe "configuring the starting id" do
  it "defines which id build_stubbed instances start with" do
    define_model("Post")

    FactoryBot.define do
      factory :post
    end

    FactoryBot.build_stubbed_starting_id = 1000

    expect(FactoryBot.build_stubbed(:post).id).to eq 1000

    FactoryBot.build_stubbed_starting_id = 3000

    expect(FactoryBot.build_stubbed(:post).id).to eq 3000
  end
end
