# encoding: utf-8
require "nokogiri"

module MoIP

  class TransparentPayment

    class << self

      # Cria uma instrução de pagamento direto
      def body(attributes = {})

        #raise "#{attributes[:valor]}--#{attributes[:valor].to_f}"
        raise(MissingPaymentTypeError, "É necessário informar a razão do pagamento") if attributes[:razao].nil?
        raise(MissingPayerError, "É obrigatório passar as informarções do pagador") if attributes[:pagador].nil?

        raise(InvalidValue, "Valor deve ser maior que zero.") if attributes[:valor].to_f <= 0.0
        raise(InvalidPhone, "Telefone deve ter o formato (99)9999-9999.") if attributes[:pagador][:tel_fixo] !~ /\(\d{2}\)?\d{4}-\d{4}/
        raise(InvalidCellphone, "Telefone celular deve ter o formato (99)9999-9999.") if attributes[:pagador][:tel_cel] !~ /\(\d{2}\)?\d{4}-\d{4}/

        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|

          # Identificador do tipo de instrução
          xml.EnviarInstrucao {
            xml.InstrucaoUnica {
            #xml.InstrucaoUnica("TipoValidacao": "Transparente") {

              # Dados da transação
              xml.Razao { xml.text attributes[:razao] }
              xml.Valores {
                xml.Valor(moeda: "BRL") { xml.text attributes[:valor] }
              }
              xml.IdProprio { xml.text attributes[:id_proprio] }

              xml.Recebedor {
                xml.LoginMoIP { xml.text attributes[:recebedor][:moip_login] }
                xml.Apelido { xml.text attributes[:recebedor][:moip_alias] }
              }

              xml.Pagador {
                xml.Nome { xml.text attributes[:pagador][:name] }
                xml.Email { xml.text attributes[:pagador][:email] }
                xml.IdPagador { xml.text attributes[:pagador][:moip_login] }
                xml.EnderecoCobranca {
                  xml.Logradouro { xml.text attributes[:pagador][:logradouro] }
                  xml.Numero { xml.text attributes[:pagador][:numero] }
                  xml.Complemento { xml.text attributes[:pagador][:complemento] }
                  xml.Bairro { xml.text attributes[:pagador][:bairro] }
                  xml.Cidade { xml.text attributes[:pagador][:cidade] }
                  xml.Estado { xml.text attributes[:pagador][:estado] }
                  xml.Pais { xml.text attributes[:pagador][:pais] }
                  xml.CEP { xml.text attributes[:pagador][:cep] }
                  xml.TelefoneFixo { xml.text attributes[:pagador][:tel_fixo] }
                }
              }
 
              xml.FormasPagamento {
                xml.FormaPagamento { xml.text "CartaoCredito" }
                xml.FormaPagamento { xml.text "CartaoDebito" }
                xml.FormaPagamento { xml.text "DebitoBancario" }
                xml.FormaPagamento { xml.text "FinanciamentoBancario" }
                xml.FormaPagamento { xml.text "BoletoBancario" }
              }
              
              if attributes[:url_retorno]
                # URL de retorno
                xml.URLRetorno {
                  xml.text attributes[:url_retorno]
                }
              end
                
            }
          }
        end

        builder.to_xml
      end

    end

  end

end
