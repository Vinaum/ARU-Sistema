#encoding: utf-8

class Servico < ActiveRecord::Base
	self.per_page = 5
	before_save :titleize_endereco
	before_validation :downcase_site
	before_destroy :find_categorias
	after_destroy :destroy_categorias_vazias

	has_many :categorizations, dependent: :destroy
	has_many :categorias, through: :categorizations, after_remove: :destroy_category_if_empty
	belongs_to :republica
	has_many :comentarios, dependent: :destroy

	accepts_nested_attributes_for :categorias, :reject_if => :all_blank

	attr_accessible :avaliacao, :endereco, :descricao, :email, :nome, :preco,
	:site, :tel1, :tel2
	attr_accessible :categorias_attributes, :categoria_ids

	validates :avaliacao, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5}
	validates :preco, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
	validates_format_of :email, :with => /^\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i, message: 'Email inválido', allow_blank: true
	validates :nome, presence: true
	validates :descricao, presence: true, length: {minimum: 30, maximum: 500}
	validates_format_of :site, :with => URI::regexp(%w(http https)), message: "Por favor, insira o link completo, com http(s).", allow_blank: true
	validates :tel1, presence: {message: "Pelo menos um número deve estar presente."}

	validate :has_a_category
	validate :max_of_3_categories

	delegate :check_categoria_empty, to: :categorias

	def any_new_categorias?
		self.categorias.each do |cat|
			if cat.new_record?
				return true
			end
		end
		false
	end

	def destroy_category_if_empty(categoria)
		if categoria.servicos.count.zero?
			categoria.destroy
		end
	end


	private

	def find_categorias
		@categorias = self.categorias
	end

	def destroy_categorias_vazias
		@categorias.each do |cat|
			cat.destroy if cat.servicos.count.zero?
		end  
	end

	def downcase_site
		self.site.downcase! if self.site.present?
	end

	def titleize_endereco
		if self.endereco?
			self.endereco = self.endereco.titleize
		end
	end

	def has_a_category
		if self.categorias.blank?
			self.errors.add(:base, "Você deve selecionar uma categoria ou criar uma nova.")
		end		
	end

	def max_of_3_categories
		if self.categorias.length > 3
			self.errors.add(:base, "Você só pode selecionar no máximo 3 categorias.")
		end		
	end

end
