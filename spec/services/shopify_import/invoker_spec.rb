require 'spec_helper'

RSpec.describe ShopifyImport::Invoker do
  describe '#import!' do
    before do
      allow(ShopifyImport::Client.instance).to receive(:get_connection)
      ShopifyImport::Invoker::ROOT_FETCHERS.each do |importer|
        allow_any_instance_of(importer).to receive(:import!)
      end
    end

    context 'with credentials parameter' do
      let(:credentials) do
        {
          api_key: 'api_key', password: 'password',
          shop_domain: 'spree-shopify-importer-test-store.myshopify.com'
        }
      end

      it 'gets the connection from the client' do
        ShopifyImport::Invoker.new(credentials: credentials).import!

        expect(ShopifyImport::Client.instance).to have_received(:get_connection).with(credentials)
      end

      it 'calls all the importers' do
        ShopifyImport::Invoker::ROOT_FETCHERS.each do |importer|
          expect_any_instance_of(importer).to receive(:import!)
        end

        ShopifyImport::Invoker.new(credentials: credentials).import!
      end
    end

    context 'with config credentials' do
      before do
        Spree::Config[:shopify_api_key] = 'api_key'
        Spree::Config[:shopify_password] = 'password'
        Spree::Config[:shopify_shop_domain] = 'spree-shopify-importer-test-store.myshopify.com'
      end

      it 'creates connection to Shopify API using preferences' do
        ShopifyImport::Invoker.new.import!

        expect(ShopifyImport::Client.instance).to have_received(:get_connection).with(
          api_key: Spree::Config[:shopify_api_key],
          password: Spree::Config[:shopify_password],
          shop_domain: Spree::Config[:shopify_shop_domain],
          token: nil
        )
      end
    end
  end
end
