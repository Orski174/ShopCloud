'use strict';

module.exports = {
  async up(queryInterface) {
    await queryInterface.bulkInsert('categories', [
      {
        id: 'a1b2c3d4-0001-0001-0001-000000000001',
        name: 'Electronics',
        slug: 'electronics',
        description: 'Gadgets, devices, and tech accessories',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        id: 'a1b2c3d4-0001-0001-0001-000000000002',
        name: 'Clothing',
        slug: 'clothing',
        description: 'Men, women, and kids apparel',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        id: 'a1b2c3d4-0001-0001-0001-000000000003',
        name: 'Home & Kitchen',
        slug: 'home-kitchen',
        description: 'Furniture, appliances, and kitchenware',
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        id: 'a1b2c3d4-0001-0001-0001-000000000004',
        name: 'Books',
        slug: 'books',
        description: 'Fiction, non-fiction, technical, and more',
        created_at: new Date(),
        updated_at: new Date(),
      },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('categories', null, {});
  },
};
