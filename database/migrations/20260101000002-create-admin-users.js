'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('admin_users', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.literal('gen_random_uuid()'),
        primaryKey: true,
      },
      email: {
        type: Sequelize.STRING(255),
        allowNull: false,
        unique: true,
      },
      password_hash: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      role: {
        type: Sequelize.ENUM('admin', 'warehouse_staff'),
        allowNull: false,
        defaultValue: 'warehouse_staff',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('NOW()'),
      },
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('admin_users');
    await queryInterface.sequelize.query("DROP TYPE IF EXISTS enum_admin_users_role;");
  },
};
