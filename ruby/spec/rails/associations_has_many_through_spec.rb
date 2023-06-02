require "active_record"
require "logger"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT, level: Logger::ERROR)

RSpec.describe "ActiveRecord has_many :through" do
  context "many-to-many relationship" do

    #
    # has_many :through
    # Can be used to model many-to-many relationships.
    #

    before :context do
      ActiveRecord::Schema.define do
        create_table :physicians, force: true do |t|
        end

        create_table :patients, force: true do |t|
        end

        create_table :appointments, force: true do |t|
          t.belongs_to :physician
          t.belongs_to :patient
        end
      end

      class Physician < ActiveRecord::Base
        has_many :appointments
        has_many :patients, through: :appointments
      end

      class Patient < ActiveRecord::Base
        has_many :appointments
        has_many :physicians, through: :appointments
      end

      class Appointment < ActiveRecord::Base
        belongs_to :physician
        belongs_to :patient
      end
    end

    let(:physician) do
      ps = Physician.create!
      Appointment.create!(physician: ps, patient: Patient.create!)
      Appointment.create!(physician: ps, patient: Patient.create!)
      Appointment.create!(physician: ps, patient: Patient.create!)
      ps
    end

    let(:patient) do
      pt = Patient.create!
      Appointment.create!(physician: Physician.create!, patient: pt)
      Appointment.create!(physician: Physician.create!, patient: pt)
      Appointment.create!(physician: Physician.create!, patient: pt)
      pt
    end

    it "should allow a physician to access his patients" do
      expect(physician.patients).to_not be_empty
    end

    it "should allow a patient to access his physicians" do
      expect(patient.physicians).to_not be_empty
    end
  end

  context "shortcut through nested has_many" do

    #
    # has_many :through
    # Can be used to "shortcut" through nested has_many associations.

    before :context do
      ActiveRecord::Schema.define do
        create_table :documents, force: true do |t|
        end

        create_table :sections, force: true do |t|
          t.belongs_to :document
        end

        create_table :paragraphs, force: true do |t|
          t.belongs_to :section
        end
      end

      class Document < ActiveRecord::Base
        has_many :sections
        has_many :paragraphs, through: :sections
      end

      class Section < ActiveRecord::Base
        belongs_to :document
        has_many :paragraphs
      end

      class Paragraph < ActiveRecord::Base
        belongs_to :section
      end
    end

    it "should allow Document to access its paragraphs" do
      doc = Document.create!

      sec1 = doc.sections.create!
      p1sec1 = sec1.paragraphs.create!
      p2sec1 = sec1.paragraphs.create!

      sec2 = doc.sections.create!
      p1sec2 = sec2.paragraphs.create!
      p2sec2 = sec2.paragraphs.create!

      expect(doc.paragraphs.to_a).to contain_exactly(p1sec1, p2sec1, p1sec2, p2sec2)
    end
  end
end